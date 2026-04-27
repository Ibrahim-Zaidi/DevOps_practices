terraform {
  required_version = ">= 1.5.0" 

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.1.0" 
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id

  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }

    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

data "azurerm_client_config" "current" {}


resource "azurerm_resource_group" "main" {
  name     = "rg-qrapp-${var.environment}" 
  location = var.location
  tags = local.common_tags
}

locals {
  common_tags = {
    project     = "qr-code-generator"
    environment = var.environment
    managed_by  = "terraform"
    owner       = "your-name"
  }
}

// Modules

module "monitoring" {
  source              = "../../modules/monitoring" 
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  tags                = local.common_tags
}

module "acr" {
  source              = "../../modules/acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  tags                = local.common_tags
}

module "aks" {
  source              = "../../modules/aks"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  node_count          = var.node_count
  node_vm_size        = var.node_vm_size
  acr_id              = module.acr.acr_id  # Pass ACR ID so AKS can pull images
  log_analytics_workspace_id = module.monitoring.workspace_id
  tags                = local.common_tags 
}

module "keyvault" {
  source              = "../../modules/keyvault"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  tenant_id           = data.azurerm_client_config.current.tenant_id 
  admin_object_id     = data.azurerm_client_config.current.object_id
  log_analytics_workspace_id = module.monitoring.workspace_id
  tags                = local.common_tags
}