output "func_windows_app_id" {
  value       = azurerm_windows_function_app.main[*].id
  description = "The ID of the function app"
}
output "func_windows_app_default_hostname" {
  value       = azurerm_windows_function_app.main[*].default_hostname
  description = "The default hostname of the function app"
}
output "func_windows_app_principal_id" {
  description = "The principal ID of the web app"
  value       = azurerm_windows_function_app.main[*].identity[0].principal_id
}
output "func_windows_app_name" {
  value       = azurerm_windows_function_app.main[*].name
  description = "The name of the function app"
}
output "func_linux_app_id" {
  value       = azurerm_linux_function_app.main[*].id
  description = "The ID of the function app"
}
output "func_linux_app_default_hostname" {
  value       = azurerm_linux_function_app.main[*].default_hostname
  description = "The default hostname of the function app"
}
output "func_linux_app_principal_id" {
  description = "The principal ID of the web app"
  value       = azurerm_linux_function_app.main[*].identity[0].principal_id
}
output "func_linux_app_name" {
  value       = azurerm_linux_function_app.main[*].name
  description = "The name of the function app"
}
output "storage_account_name" {
  value       = azurerm_storage_account.main.name
  description = "The name of the storage account which backs the function app"
}
output "storage_account_id" {
  value       = azurerm_storage_account.main.id
  description = "The ID of the storage account which backs the function app"
}
output "storage_account_primary_access_key" {
  value       = azurerm_storage_account.main.primary_access_key
  description = "The primary access key of the storage account which backs the function app"
  sensitive   = true
}
