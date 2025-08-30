# common values for all the test runs
variables {
  func_name           = "zen-terraform-func-test"
  resource_group_name = "func-app"
  location            = "australiasoutheast"
  service_plan_id     = "/subscriptions/992dc453-8c7a-44c9-bfe3-991c6f6c6f2c/resourceGroups/zentral-nprd-rg/providers/Microsoft.Web/serverFarms/zentral-win-nprd-asp"
  os_type             = "windows"
  app_settings = {
    abcd = 1
  }
  tags = {
    environment = "dev"
    costcenter  = "it"
  }
}

# initialize the provider
provider "azurerm" {
  subscription_id     = "992dc453-8c7a-44c9-bfe3-991c6f6c6f2c"
  storage_use_azuread = true
  features {}
}

# setup the resource group in which function app will be created
run "setup_resource_group" {
  command = apply

  variables {
    resource_group_name = var.resource_group_name
    location            = var.location
  }

  module {
    source = "./tests/setup"
  }
}

# unit test case to check plan is without errors
run "func_app_plan_validation" {
  command = plan

  variables {
    resource_group_name           = run.setup_resource_group.resource_group_name
    application_connection_string = run.setup_resource_group.app_insights_connection_string
    action_group_id               = run.setup_resource_group.action_group_id
    scopes                        = run.setup_resource_group.app_insights_id
  }
}

run "func_app_plan_with_optional_variables" {
  command = plan

  variables {
    resource_group_name           = run.setup_resource_group.resource_group_name
    application_connection_string = run.setup_resource_group.app_insights_connection_string
    action_group_id               = run.setup_resource_group.action_group_id
    scopes                        = run.setup_resource_group.app_insights_id
    cors_policy = {
      allowed_origins     = ["*"]
      support_credentials = true
    }
    whitelist_ips = [
      {
        name   = "whitelist-home-ip"
        source = "10.0.0.0/23"
      }
    ]
  }
}


# unit test case to check func app mandatory variables apply
run "func_app_mandatory_variables_apply_test" {
  command = apply

  variables {
    resource_group_name           = run.setup_resource_group.resource_group_name
    application_connection_string = run.setup_resource_group.app_insights_connection_string
    action_group_id               = run.setup_resource_group.action_group_id
    scopes                        = run.setup_resource_group.app_insights_id
  }

  assert {
    condition     = azurerm_windows_function_app.main[0].name == "zen-terraform-func-test-func"
    error_message = "App service name is not as expected"
  }
  assert {
    condition     = azurerm_windows_function_app.main[0].service_plan_id == "/subscriptions/ae0b1cb9-9226-4ff8-a1b0-f788b488489a/resourceGroups/zentral-nprd-rg/providers/Microsoft.Web/serverFarms/zentral-win-nprd-asp"
    error_message = "App service plan id is not as expected"
  }
  assert {
    condition     = azurerm_windows_function_app.main[0].location == "australiasoutheast"
    error_message = "App service location is not as expected"
  }
  assert {
    condition     = azurerm_windows_function_app.main[0].identity[0].type == "SystemAssigned"
    error_message = "App service identity type is not as expected"
  }
  assert {
    condition     = azurerm_windows_function_app.main[0].identity[0].principal_id != null
    error_message = "App service identity id is not as expected"
  }
  assert {
    condition     = azurerm_storage_account.main.name != null
    error_message = "Storage account name is not as expected"
  }
  assert {
    condition     = azurerm_storage_account.main.primary_access_key != null
    error_message = "Storage account primary access key is not as expected"
  }
}
