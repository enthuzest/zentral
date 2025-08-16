locals {
  default_app_settings = {

  }
}

resource "random_string" "random" {
  length  = 10
  lower   = true
  upper   = false
  special = false
}

resource "azurerm_storage_account" "main" {
  name                     = random_string.random.id
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_windows_function_app" "main" {
  count               = var.os_type == "windows" ? 1 : 0
  name                = "${var.function_app_name}-func-app"
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name          = azurerm_storage_account.main.name
  storage_account_access_key    = azurerm_storage_account.main.primary_access_key
  service_plan_id               = var.app_service_plan_id
  app_settings                  = merge(local.default_app_settings, var.app_settings)
  https_only                    = true
  public_network_access_enabled = false
  virtual_network_subnet_id     = var.virtual_network_subnet_id

  identity {
    type = "SystemAssigned"
  }
  site_config {
    always_on                              = true
    application_insights_connection_string = var.application_insights_connection_string
    application_stack {
      dotnet_version          = var.application_stack.stack == "dotnet" ? var.application_stack.dotnet_version : null
      java_version            = var.application_stack.stack == "java" ? var.application_stack.java_version : null
      node_version            = var.application_stack.stack == "node" ? var.application_stack.node_version : null
      powershell_core_version = var.application_stack.stack == "powershell" ? var.application_stack.powershell_core_version : null
    }
    dynamic "cors" {
      for_each = var.cors_policy != null ? [var.cors_policy] : []
      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }
  }
  tags = var.tags
}
