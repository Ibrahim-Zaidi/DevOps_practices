variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "tenant_id" {
  description = "Azure AD Tenant ID — required for Key Vault authentication"
  type        = string
}

variable "admin_object_id" {
  description = "Object ID of the user/SP that gets full access (you)"
  type        = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}