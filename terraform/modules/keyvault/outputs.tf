output "key_vault_id" {
  value = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "The URI apps use to retrieve secrets: https://kv-qrapp-dev.vault.azure.net/"
  value       = azurerm_key_vault.main.vault_uri
}

output "key_vault_name" {
  value = azurerm_key_vault.main.name
}