terraform {
  required_version = "=1.4.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.53.0"
    }
  }
}

terraform {
    backend "azurerm" {
        resource_group_name  = "state-nprd-rg"
        storage_account_name = "zentraltfstatenprd"
        container_name       = "state"
        key                  = "zentral/moduletesting/functionapp/terraform.tfstate"
    }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  features {}
}
