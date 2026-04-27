output "cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "cluster_id" {
  value = azurerm_kubernetes_cluster.main.id
}

output "kube_config" {
  description = "Raw kubeconfig — use this to connect kubectl to the cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true  # Contains credentials — never log this
}

output "kubelet_identity_object_id" {
  description = "Object ID of AKS nodepool identity — used for additional role assignments"
  value       = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}