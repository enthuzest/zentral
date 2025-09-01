resource "azurerm_mssql_database" "main" {
  name         = var.database_name
  server_id    = var.server_id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = var.max_size_gb
  sku_name     = var.sku_name
  short_term_retention_policy {
    retention_days = var.short_term_retention_days
  }
  elastic_pool_id = var.elastic_pool_id
  tags            = var.tags
}

resource "azurerm_mssql_failover_group" "main" {
  count     = var.failover_group.enabled ? 1 : 0
  name      = var.failover_group.failover_group_name
  server_id = var.server_id
  databases = [
    azurerm_mssql_database.main.id,
  ]

  partner_server {
    id = var.failover_group.secondary_server_id
  }

  read_write_endpoint_failover_policy {
    mode = "Manual"
  }

  tags = var.tags
}
