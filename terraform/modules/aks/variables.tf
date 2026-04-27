variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "node_count" {
  type    = number
  default = 1
}

variable "node_vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "acr_id" {
  description = "ACR resource ID to grant AKS pull permissions"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for Container Insights"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}