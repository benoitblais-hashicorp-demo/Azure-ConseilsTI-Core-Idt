locals {
  platform_workloads = ["connectivity", "identity", "management"]
  tfc_audience       = "api://AzureADTokenExchange"
  tfc_issuer         = "https://app.terraform.io"
}

# 1. Entra ID Applications
resource "azuread_application" "platform" {
  for_each     = toset(local.platform_workloads)
  display_name = "spn-lz-${each.key}"
}

# 2. Entra ID Service Principals
resource "azuread_service_principal" "platform" {
  for_each  = azuread_application.platform
  client_id = each.value.client_id
}

# 3. Federated Identity Credentials
# One unified claim mapping to the TFC Workspace for both Plan and Apply
resource "azuread_application_federated_identity_credential" "tfc" {
  for_each       = azuread_application.platform
  application_id = each.value.id
  display_name   = "tfc-${each.key}-workspace"
  description    = "Federated credential for TFC Workspace: ${var.tfc_workspace_names[each.key]}"
  audiences      = [local.tfc_audience]
  issuer         = local.tfc_issuer
  # Configure TFC to provide exactly this claim via TFC workspace settings
  subject = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_names[each.key]}"
}

# 4. Custom Role Definition for Workload Separation
resource "azurerm_role_definition" "restricted_network_contributor" {
  name        = "Platform Restricted Contributor"
  description = "Contributor access restricted from creating core networking resources. Permits Private Endpoints and Subnet Joins."
  scope       = var.management_group_id

  permissions {
    actions = [
      "*",
    ]
    not_actions = [
      "Microsoft.Network/virtualNetworks/write",
      "Microsoft.Network/virtualNetworks/delete",
      "Microsoft.Network/virtualNetworks/subnets/write",
      "Microsoft.Network/virtualNetworks/subnets/delete",
      "Microsoft.Network/routeTables/write",
      "Microsoft.Network/routeTables/delete",
      "Microsoft.Network/networkSecurityGroups/write",
      "Microsoft.Network/networkSecurityGroups/delete",
      "Microsoft.Network/expressRouteCircuits/write",
      "Microsoft.Network/expressRouteCircuits/delete",
      "Microsoft.Network/virtualHubs/write",
      "Microsoft.Network/virtualHubs/delete",
      "Microsoft.Network/vpnGateways/write",
      "Microsoft.Network/vpnGateways/delete"
    ]
  }
}

# 5. Role Assignments
# Connectivity Environment
resource "azurerm_role_assignment" "connectivity_contributor" {
  scope                = "/subscriptions/${var.connectivity_subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.platform["connectivity"].object_id
}

resource "azurerm_role_assignment" "connectivity_network_contributor_id" {
  scope                = "/subscriptions/${var.identity_subscription_id}"
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.platform["connectivity"].object_id
}

resource "azurerm_role_assignment" "connectivity_network_contributor_mgmt" {
  scope                = "/subscriptions/${var.management_subscription_id}"
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.platform["connectivity"].object_id
}

# Identity Environment
resource "azurerm_role_assignment" "identity_restricted" {
  scope              = "/subscriptions/${var.identity_subscription_id}"
  role_definition_id = azurerm_role_definition.restricted_network_contributor.role_definition_resource_id
  principal_id       = azuread_service_principal.platform["identity"].object_id
}

# Management Environment
resource "azurerm_role_assignment" "management_restricted" {
  scope              = "/subscriptions/${var.management_subscription_id}"
  role_definition_id = azurerm_role_definition.restricted_network_contributor.role_definition_resource_id
  principal_id       = azuread_service_principal.platform["management"].object_id
}

# Management Group Policy Control
resource "azurerm_role_assignment" "management_group_policy" {
  scope                = var.management_group_id
  role_definition_name = "Resource Policy Contributor"
  principal_id         = azuread_service_principal.platform["management"].object_id
}
