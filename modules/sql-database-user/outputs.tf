output "principal_id" {
  value       = azurerm_mssql_database_user.main.principal_id
  description = "The principal ID of the SQL Database User"
}
output "sid" {
  value       = azurerm_mssql_database_user.main.sid
  description = "The security identifier (SID) of this database user in String format"
} 