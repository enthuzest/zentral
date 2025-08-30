output "resource_group_name" {
  value       = azurerm_resource_group.main.name
  description = "generic"
}

output "resource_group_id" {
  value       = azurerm_resource_group.main.id
  description = "generic"
}

output "action_group_id" {
  value       = azurerm_monitor_action_group.main.id
  description = "generic"
}

output "app_insights_id" {
  value       = azurerm_application_insights.main.id
  description = "generic"
}

output "app_insights_connection_string" {
  value       = azurerm_application_insights.main.connection_string
  description = "generic"
  sensitive   = true
}
