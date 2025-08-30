resource "azurerm_resource_group" "main" {
  name     = "${var.resource_group_name}-rg"
  location = var.location
  tags     = var.tags
}

data "azuread_group" "contributors" {
  for_each     = toset(var.contributor_ad_group_names)
  display_name = each.value
}

data "azuread_group" "reader" {
  for_each     = toset(var.reader_ad_group_names)
  display_name = each.value
}

resource "azurerm_role_assignment" "contributor" {
  for_each             = toset(var.contributor_ad_group_names)
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_group.contributors[each.key].object_id
}

resource "azurerm_role_assignment" "reader" {
  for_each             = toset(var.reader_ad_group_names)
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_group.reader[each.key].object_id
}
