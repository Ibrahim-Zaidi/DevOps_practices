terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.1.0"
    }
  }
  
}

provider "azurerm" {
  features {}
  subscription_id = "db029d4c-f22f-4c1a-8b0f-224be9635f15"
}

resource "azurerm_resource_group" "tfstate" {
  name     = "rg-tfstate"
  location = "francecentral"
}

resource "azurerm_storage_account" "tfstate" {
  name                = "sqcodertfstate"
  resource_group_name = azurerm_resource_group.tfstate.name
  location            = azurerm_resource_group.tfstate.location

  account_tier             = "Standard"  
  account_replication_type = "LRS"     


  # Security settings
  min_tls_version          = "TLS1_2" 
  allow_nested_items_to_be_public = false  

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }
  }

  tags = {
    purpose = "terraform-state"
    managed_by = "manual-bootstrap" 
  }
}

resource "azurerm_storage_container" "tfstate" { 
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  
  container_access_type = "private"  
}

output "resource_group_name" {
  value = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "container_name" {
  value = azurerm_storage_container.tfstate.name
}
