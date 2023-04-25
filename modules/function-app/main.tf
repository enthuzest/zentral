resource "random_string" "random" {
  length  = 10
  lower   = true
  upper   = false
  special = false
}

resource "azurerm_storage_account" "sa" {
  name                     = random_string.random.id
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_function_app" "primary" {
  name                       = "${var.function_app_name}-func-app"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  app_service_plan_id        = var.app_service_plan_id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  app_settings               = var.app_settings
  version = var.func_version

  identity {
    type = "SystemAssigned"
  }
  site_config {
    always_on = true
    dotnet_framework_version = var.dotnet_framework_version
  }

  tags = var.tags
}