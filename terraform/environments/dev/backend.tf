# This block CANNOT use variables — it must be hardcoded or use partial config
# Terraform reads this before evaluating any variables
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"           # From bootstrap output
    storage_account_name = "sqcodertfstate"       # From bootstrap output — your unique name
    container_name       = "tfstate"               # From bootstrap output
    key                  = "dev/terraform.tfstate" # Path inside the container
    # The key acts like a folder/filename — each environment uses a different key:
    # dev/terraform.tfstate
    # staging/terraform.tfstate
    # prod/terraform.tfstate
  }
}