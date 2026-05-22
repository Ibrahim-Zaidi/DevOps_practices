resource "azurerm_container_registry" "main" {

  name                = "acrqrapp${replace(var.environment, "-", "")}" // name will be globally unique, so we append environment and remove dashes, like 
  resource_group_name = var.resource_group_name
  location            = var.location

  sku = "Basic"   
  admin_enabled = false  
  tags = var.tags
}