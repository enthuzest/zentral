output "function_app_id" {
  value = azurerm_function_app.primary.id
}

output "default_hostname" {
  value = azurerm_function_app.primary.default_hostname
}

output "function_app_kind" {
  value = azurerm_function_app.primary.kind
}

output "function_app_name" {
  value = azurerm_function_app.primary.name
}