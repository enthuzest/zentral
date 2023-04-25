resource "azurerm_storage_account" "sa" {
  name                     = "functionsapptestsa"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_function_app" "primary" {
  name                       = var.function_app_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.example.id
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key

  app_settings = {
        var.app_settings
  }
  identity = {
    type = "SystemAssigned"
  }
  site_config = {
        always_on = true
  }
  dotnet_framework_version = var.dotnet_framework_version
  version = var.version
  tags = var.tags
}