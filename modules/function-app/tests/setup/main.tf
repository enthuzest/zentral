terraform {
  required_version = "~>1.12.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.3.0"
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = "none"
  subscription_id                 = "992dc453-8c7a-44c9-bfe3-991c6f6c6f2c"
  features {}
  alias = "user"
}

data "azurerm_key_vault" "zentral_kv" {
  name                = "zentral-nprd-kv"
  resource_group_name = "zentral-nprd-rg"
  provider            = azurerm.user
}

data "azurerm_key_vault_secret" "client_secret" {
  name         = "arm-client-secret"
  key_vault_id = data.azurerm_key_vault.zentral_kv.id
  provider     = azurerm.user
}

data "azurerm_key_vault_secret" "client_id" {
  name         = "arm-client-id"
  key_vault_id = data.azurerm_key_vault.zentral_kv.id
  provider     = azurerm.user
}

provider "azurerm" {
  resource_provider_registrations = "none"
  client_id                       = data.azurerm_key_vault_secret.client_id.value
  client_secret                   = data.azurerm_key_vault_secret.client_secret.value
  tenant_id                       = "78ca5159-6d10-4edb-b73b-9ed9b98fd637"
  subscription_id                 = "992dc453-8c7a-44c9-bfe3-991c6f6c6f2c"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "main" {
  name     = "terraform-test-${var.resource_group_name}-rg"
  location = var.location
}

# resource "azurerm_role_assignment" "main" {
#   scope                = azurerm_resource_group.main.id
#   role_definition_name = "Owner"
#   principal_id         = "xxxxx"
# }

resource "azurerm_monitor_action_group" "main" {
  name                = "tf-test-func-ag"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "p0action"
}

resource "azurerm_application_insights" "main" {
  name                = "tf-test-func-appinsights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
}
