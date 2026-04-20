variable "subscription_id" {
  description = "The Azure Subscription ID used for the current deployment context."
  type        = string
}

variable "tenant_id" {
  description = "The Azure Active Directory tenant ID."
  type        = string
}

variable "connectivity_subscription_id" {
  description = "Subscription ID for the Connectivity Landing Zone."
  type        = string
}

variable "identity_subscription_id" {
  description = "Subscription ID for the Identity Landing Zone."
  type        = string
}

variable "management_subscription_id" {
  description = "Subscription ID for the Management Landing Zone."
  type        = string
}

variable "management_group_id" {
  description = "The Management Group ID where policy roles will be assigned (Root or Platform)."
  type        = string
}

variable "tfc_organization_name" {
  description = "Terraform Cloud Organization Name."
  type        = string
}

variable "tfc_project_name" {
  description = "Terraform Cloud Project Name."
  type        = string
}

variable "tfc_workspace_names" {
  description = "Map of Terraform Cloud workspace names for the environments (connectivity, identity, management)."
  type        = map(string)
}
