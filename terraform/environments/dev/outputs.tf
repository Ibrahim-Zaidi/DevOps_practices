output "resource_group_id" {
  value = azurerm_resource_group.main.id
}

output "acr_id" {
  value = module.acr.acr_id
}

output "aks_cluster_id" {
  value = module.aks.cluster_id
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "acr_login_server" {
  description = "Docker registry URL: docker push <this>/qr-api:latest"
  value       = module.acr.login_server
}

output "acr_name" {
  value = module.acr.name
}

output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "key_vault_uri" {
  value = module.keyvault.key_vault_uri
}

output "connect_kubectl_command" {
  description = "Run this to configure kubectl after apply"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${module.aks.cluster_name}"  
}