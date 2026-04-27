# Outputs expose values from this module to the parent (environments/dev/main.tf)
# Other modules reference these values: module.monitoring.workspace_id
output "workspace_id" {
  description = "Log Analytics Workspace resource ID — used by AKS and Key Vault"
  value       = azurerm_log_analytics_workspace.main.id
}

output "workspace_name" {
  value = azurerm_log_analytics_workspace.main.name
}

output "workspace_key" {
  description = "Primary key for the workspace — sensitive, won't show in plain text"
  value       = azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive   = true  # Terraform masks this in CLI output and state diffs
}