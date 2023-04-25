locals {
  application_name                      = random_string.id.result
  application_name_with_sub_environment = local.application_name
  location                              = "australiasoutheast"

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.appi.instrumentation_key
    WEBSITE_RUN_FROM_PACKAGE       = 1
  }

  tags = {
    "BusinessOwner"  = "alpha pandey"
    "CostCode"       = "C4-420"
    "TechnicalOwner" = "beta biswas"
  }
}

resource "random_string" "id" {
  length    = 12
  min_lower = 12
  number    = false
  special   = false
}

resource "azurerm_resource_group" "primary_rg" {
  name     = "${local.application_name_with_sub_environment}-rg"
  location = local.location
}

resource "azurerm_app_service_plan" "test_primary" {
  name                = "${local.application_name_with_sub_environment}-asp"
  location            = azurerm_resource_group.primary_rg.location
  resource_group_name = azurerm_resource_group.primary_rg.name

  kind = "Windows"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_application_insights" "appi" {
  name                = "${local.application_name_with_sub_environment}-appi"
  location            = azurerm_resource_group.primary_rg.location
  resource_group_name = azurerm_resource_group.primary_rg.name
  application_type    = "web"
}

module "backend-func-app" {
  source              = "github.com/faraz841/Zentral/modules/function-app"
  function_app_name   = local.application_name_with_sub_environment
  resource_group_name = azurerm_resource_group.primary_rg.name
  app_service_plan_id = azurerm_app_service_plan.test_primary.id
  location            = azurerm_resource_group.primary_rg.location
  app_settings        = local.app_settings
  tags                = local.tags
}
