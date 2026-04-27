output "acr_id" {
  description = "Resource ID — needed to grant AKS pull access via role assignment"
  value       = azurerm_container_registry.main.id
}

output "login_server" {
  description = "The URL your Docker CLI uses to push/pull: acrqrappdev.azurecr.io"
  value       = azurerm_container_registry.main.login_server
}

output "name" {
  value = azurerm_container_registry.main.name
}