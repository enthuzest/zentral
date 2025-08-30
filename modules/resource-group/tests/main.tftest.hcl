# common values for all the test runs
variables {
  resource_group_name        = "terraform-test"
  location                   = "australiasoutheast"
  contributor_ad_group_names = []
  tags = {
    environment = "dev"
    costcenter  = "it"
  }
}

# initialize the provider
provider "azurerm" {
  subscription_id = "992dc453-8c7a-44c9-bfe3-991c6f6c6f2c"
  features {}
}

# unit test case to check variable validation
run "resource_group_variable_validation" {
  command = plan

  variables {
    location = "eastus"
  }

  expect_failures = [
    var.location
  ]
}

run "resource_group_apply_test" {
  command = apply

  assert {
    condition     = azurerm_resource_group.main.name == "terraform-test-rg"
    error_message = "Resource group name does not match the expected value"
  }
}