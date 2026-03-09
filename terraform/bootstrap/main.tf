terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.1.0"
    }
  }
  # Bootstrap uses LOCAL state intentionally — it only manages
  # the storage account, which almost never changes
}

provider "azurerm" {
  features {}
  subscription_id = "db029d4c-f22f-4c1a-8b0f-224be9635f15"
}

# This resource group holds ONLY the Terraform state infrastructure
# It's separate from your app resource group — different lifecycle
resource "azurerm_resource_group" "tfstate" {
  name     = "rg-tfstate"
  location = "francecentral"
}

# A Storage Account is Azure's equivalent of an S3 bucket
# Naming rules: 3-24 chars, lowercase, alphanumeric only, globally unique
resource "azurerm_storage_account" "tfstate" {
  name                = "sqcodertfstate"
  resource_group_name = azurerm_resource_group.tfstate.name
  location            = azurerm_resource_group.tfstate.location

  account_tier             = "Standard"  
  account_replication_type = "LRS"     

  # Security settings
  min_tls_version          = "TLS1_2" 
  allow_nested_items_to_be_public = false  # No anonymous access

  # Enable versioning so you can recover from bad state
  blob_properties {
    versioning_enabled = true

    # Keep deleted blobs for 7 days
    delete_retention_policy {
      days = 7
    }
  }

  tags = {
    purpose = "terraform-state"
    managed_by = "manual-bootstrap" 
  }
}

# This is where the actual .tfstate files live
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  
  container_access_type = "private"  # No public access — state has secrets!
}

# Output the values you'll need for backend.tf in each environment
output "resource_group_name" {
  value = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "container_name" {
  value = azurerm_storage_container.tfstate.name
}
