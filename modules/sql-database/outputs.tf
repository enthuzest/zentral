output "id" {
  value       = azurerm_mssql_database.main.id
  description = "The ID of the MS SQL Database"
}
output "database_name" {
  value       = azurerm_mssql_database.main.name
  description = "The name of the MS SQL Database"
}