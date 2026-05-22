resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-qrapp-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "qrapp-${var.environment}"  

  identity {
    type = "SystemAssigned"
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # ── Default Node Pool ─────────────────────────────────────────────────────────
  # A node pool is a group of VMs that run your pods
  # You can have multiple node pools (e.g., one for CPU-heavy, one for GPU workloads)
  default_node_pool {
    name       = "system"      # "system" pool runs Kubernetes system components
    node_count = var.node_count
    vm_size    = var.node_vm_size

    os_disk_size_gb = 30  


    upgrade_settings {
      max_surge = "10%"  
    }
  }

  # ── Monitoring Integration ────────────────────────────────────────────────────
  # Sends container logs and metrics to Log Analytics
  # Enables "Insights" tab in Azure Portal for this cluster
  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  # ── Network Profile ───────────────────────────────────────────────────────────
  network_profile {
    network_plugin = "azure"      # Azure CNI — each pod gets a real Azure VNet IP
                                   # (vs. kubenet where pods use overlay network)
    dns_service_ip = "10.0.0.10"
    service_cidr   = "10.0.0.0/16"
  }

  tags = var.tags
}

# ── Role Assignment: AKS → ACR ────────────────────────────────────────────────
# Grants AKS's kubelet identity the "AcrPull" role on the ACR
# This means Kubernetes can pull Docker images WITHOUT a password
# It uses Azure's identity system instead — much more secure
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true  # Required for managed identities
}