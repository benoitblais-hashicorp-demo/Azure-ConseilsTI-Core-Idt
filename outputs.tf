output "platform_service_principals" {
  description = "A map of created Service Principals and their essential attributes."
  value = {
    for k, v in azuread_service_principal.platform : k => {
      client_id        = v.client_id
      object_id        = v.object_id
      application_name = azuread_application.platform[k].display_name
    }
  }
}

output "restricted_network_contributor_role_id" {
  description = "The Resource ID for the custom Platform Restricted Contributor role."
  value       = azurerm_role_definition.restricted_network_contributor.role_definition_resource_id
}
