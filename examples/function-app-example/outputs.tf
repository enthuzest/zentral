output "resource_group_name" {
  value = azurerm_resource_group.primary_rg.name
}

output "function_app_id" {
  value = module.backend-func-app.function_app_id
}

output "default_hostname" {
  value = module.backend-func-app.default_hostname
}

output "function_app_kind" {
  value = module.backend-func-app.function_app_kind
}

output "function_app_name" {
  value = module.backend-func-app.function_app_name
}