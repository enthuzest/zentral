locals {
  default_whitelist_ip = [{
    name   = "Deny all access"
    source = "0.0.0.0/0"
  }]
  default_custom_alert = {
    custom_alert = {
      alert_name              = "custom-alert-${var.func_name}-func-exception"
      description             = "any exception in ${var.func_name}-func"
      query                   = format("exceptions | where cloud_RoleName == '%s' and timestamp > ago(5m)", "${var.func_name}-func")
      severity                = 1
      frequency               = "PT5M"
      time_window             = "PT5M"
      operator                = "GreaterThan"
      threshold               = 0
      time_aggregation_method = "Count"
    }
  }
  default_metric_alert = {
    http4xx_alert = {
      alert_name       = "http4xx-alert-${var.func_name}-func"
      description      = "Http4xx error in ${var.func_name}-func"
      metric_namespace = "microsoft.web/sites"
      metric_name      = "Http4xx"
      aggregation      = "Total"
      operator         = "GreaterThan"
      threshold        = 1
      severity         = 1
    },
    http5xx_alert = {
      alert_name       = "http5xx-alert-${var.func_name}-func"
      description      = "Http5xx error in ${var.func_name}-func"
      metric_namespace = "microsoft.web/sites"
      metric_name      = "Http5xx"
      aggregation      = "Total"
      operator         = "GreaterThan"
      threshold        = 1
      severity         = 1
    }
  }
}

data "azurerm_resource_group" "private_vnet_rg" {
  count = var.private_endpoint.enabled ? 1 : 0
  name  = var.private_endpoint.vnet_resource_group_name
}

data "azurerm_virtual_network" "private_vnet" {
  count               = var.private_endpoint.enabled ? 1 : 0
  name                = var.private_endpoint.vnet_name
  resource_group_name = data.azurerm_resource_group.private_vnet_rg[0].name
}

data "azurerm_subnet" "private_subnet" {
  count                = var.private_endpoint.enabled ? 1 : 0
  name                 = var.private_endpoint.vnet_subnet_name
  virtual_network_name = data.azurerm_virtual_network.private_vnet[0].name
  resource_group_name  = data.azurerm_resource_group.private_vnet_rg[0].name
}

data "azurerm_resource_group" "private_dns_rg" {
  count = var.private_endpoint.enabled ? 1 : 0
  name  = var.private_endpoint.private_dns_zone_resource_group_name
}

data "azurerm_private_dns_zone" "sa_private_dns_zone" {
  count               = var.private_endpoint.enabled ? 1 : 0
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = data.azurerm_resource_group.private_dns_rg[0].name
}

data "azurerm_private_dns_zone" "sa_queue_private_dns_zone" {
  count               = var.private_endpoint.enabled ? 1 : 0
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = data.azurerm_resource_group.private_dns_rg[0].name
}

data "azurerm_private_dns_zone" "func_private_dns_zone" {
  count               = var.private_endpoint.enabled ? 1 : 0
  name                = "privatelink.azurewebsites.net"
  resource_group_name = data.azurerm_resource_group.private_dns_rg[0].name
}

resource "random_string" "random" {
  length  = 10
  special = false
  upper   = false
}

resource "azurerm_storage_account" "main" {
  #checkov:skip=CKV_AZURE_33:Skipping as Function app storage account does not have queue service enabled
  #checkov:skip=CKV2_AZURE_1:Skipping as customer Managed Key is not required at the moment
  #checkov:skip=CKV2_AZURE_40: Skipping as shared_access_key_enabled is dynamic and application can choose with respect to its requirements
  name                            = random_string.random.result
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "GRS"
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = var.public_network_access_enabled != null ? var.public_network_access_enabled : var.private_endpoint.enabled ? false : true
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = var.shared_access_key_enabled

  network_rules {
    default_action             = var.storage_account_network_rules.default_action
    ip_rules                   = var.storage_account_network_rules.ip_rules
    virtual_network_subnet_ids = var.storage_account_network_rules.virtual_network_subnet_ids
  }

  blob_properties {
    delete_retention_policy {
      days = 5
    }
  }
  sas_policy {
    expiration_period = "01.00:00:00" # DD.HH:MM:SS
  }
  tags = var.tags
}

resource "azurerm_storage_queue" "queue" {
  count                = var.storage_queue_names != null ? length(var.storage_queue_names) : 0
  name                 = var.storage_queue_names[count.index]
  storage_account_name = azurerm_storage_account.main.name
}

resource "azurerm_private_endpoint" "queue" {
  count               = (var.private_endpoint.enabled && var.storage_queue_names != null) ? 1 : 0
  name                = "${azurerm_storage_account.main.name}-queue-private-endpoint"
  resource_group_name = data.azurerm_resource_group.private_vnet_rg[0].name
  location            = data.azurerm_resource_group.private_vnet_rg[0].location
  subnet_id           = data.azurerm_subnet.private_subnet[0].id
  tags                = var.tags
  private_service_connection {
    name                           = "${azurerm_storage_account.main.name}-queue-private-service-connection"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["queue"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "${azurerm_storage_account.main.name}-queue-private-dns-zone-group"
    private_dns_zone_ids = [var.private_endpoint.enabled ? data.azurerm_private_dns_zone.sa_queue_private_dns_zone[0].id : null]
  }
}

resource "azurerm_private_endpoint" "storage" {
  count               = var.private_endpoint.enabled ? 1 : 0
  name                = "${azurerm_storage_account.main.name}-private-endpoint"
  resource_group_name = data.azurerm_resource_group.private_vnet_rg[0].name
  location            = data.azurerm_resource_group.private_vnet_rg[0].location
  subnet_id           = data.azurerm_subnet.private_subnet[0].id
  tags                = var.tags
  private_service_connection {
    name                           = "${azurerm_storage_account.main.name}-private-service-connection"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "${azurerm_storage_account.main.name}-private-dns-zone-group"
    private_dns_zone_ids = [var.private_endpoint.enabled ? data.azurerm_private_dns_zone.sa_private_dns_zone[0].id : null]
  }
}

resource "azurerm_windows_function_app" "main" {
  count                         = var.os_type == "windows" ? 1 : 0
  name                          = "${var.func_name}-func"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  storage_account_name          = azurerm_storage_account.main.name
  storage_account_access_key    = azurerm_storage_account.main.primary_access_key
  service_plan_id               = var.service_plan_id
  app_settings                  = var.app_settings
  functions_extension_version   = var.functions_extension_version
  virtual_network_subnet_id     = var.virtual_network_subnet_id
  public_network_access_enabled = var.func_public_network_access_enabled
  https_only                    = true
  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                              = var.always_on
    application_insights_connection_string = var.application_connection_string
    http2_enabled                          = true
    application_stack {
      dotnet_version              = "v${var.application_stack.dotnet_version}"
      use_dotnet_isolated_runtime = var.application_stack.use_dotnet_isolated_runtime
      node_version                = var.application_stack.node_version
    }
    dynamic "cors" {
      for_each = var.cors_policy == null ? [] : [var.cors_policy]
      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }
    dynamic "ip_restriction" {
      for_each = var.whitelist_ips == null ? local.default_whitelist_ip : var.whitelist_ips
      content {
        action     = var.whitelist_ips == null ? "Deny" : "Allow"
        priority   = index(var.whitelist_ips == null ? local.default_whitelist_ip : var.whitelist_ips, ip_restriction.value) + 100
        name       = ip_restriction.value.name
        ip_address = ip_restriction.value.source
      }
    }

    scm_use_main_ip_restriction       = false
    scm_ip_restriction_default_action = "Deny"
    ip_restriction_default_action     = "Deny"

    dynamic "scm_ip_restriction" {
      for_each = var.scm_allowed_ips == null ? [] : var.scm_allowed_ips
      content {
        action     = "Allow"
        priority   = index(var.scm_allowed_ips, scm_ip_restriction.value) + 100
        name       = scm_ip_restriction.value.name
        ip_address = scm_ip_restriction.value.source
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = var.scm_allowed_subnet_ids == null ? [] : var.scm_allowed_subnet_ids
      content {
        action                    = "Allow"
        priority                  = index(var.scm_allowed_subnet_ids, scm_ip_restriction.value) + 200
        name                      = scm_ip_restriction.value.name
        virtual_network_subnet_id = scm_ip_restriction.value.subnet_id
      }
    }
  }

  tags = var.tags
}

resource "azurerm_windows_function_app_slot" "slot" {
  count                         = (var.create_slot && var.os_type == "windows") ? 1 : 0
  name                          = "${var.func_name}-slot-func"
  function_app_id               = azurerm_windows_function_app.main[0].id
  storage_account_name          = azurerm_storage_account.main.name
  app_settings                  = var.app_settings
  functions_extension_version   = var.functions_extension_version
  virtual_network_subnet_id     = var.virtual_network_subnet_id
  public_network_access_enabled = var.func_public_network_access_enabled
  https_only                    = true
  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                              = var.always_on
    application_insights_connection_string = var.application_connection_string
    http2_enabled                          = true
    application_stack {
      dotnet_version              = "v${var.application_stack.dotnet_version}"
      use_dotnet_isolated_runtime = var.application_stack.use_dotnet_isolated_runtime
      node_version                = var.application_stack.node_version
    }
    dynamic "cors" {
      for_each = var.cors_policy == null ? [] : [var.cors_policy]
      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }
    dynamic "ip_restriction" {
      for_each = var.whitelist_ips == null ? local.default_whitelist_ip : var.whitelist_ips
      content {
        action     = var.whitelist_ips == null ? "Deny" : "Allow"
        priority   = index(var.whitelist_ips == null ? local.default_whitelist_ip : var.whitelist_ips, ip_restriction.value) + 100
        name       = ip_restriction.value.name
        ip_address = ip_restriction.value.source
      }
    }

    scm_use_main_ip_restriction       = false
    scm_ip_restriction_default_action = "Deny"
    ip_restriction_default_action     = "Deny"

    dynamic "scm_ip_restriction" {
      for_each = var.scm_allowed_ips == null ? [] : var.scm_allowed_ips
      content {
        action     = "Allow"
        priority   = index(var.scm_allowed_ips, scm_ip_restriction.value) + 100
        name       = scm_ip_restriction.value.name
        ip_address = scm_ip_restriction.value.source
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = var.scm_allowed_subnet_ids == null ? [] : var.scm_allowed_subnet_ids
      content {
        action                    = "Allow"
        priority                  = index(var.scm_allowed_subnet_ids, scm_ip_restriction.value) + 200
        name                      = scm_ip_restriction.value.name
        virtual_network_subnet_id = scm_ip_restriction.value.subnet_id
      }
    }
  }

  tags = var.tags
}

resource "azurerm_linux_function_app" "main" {
  count                         = var.os_type == "linux" ? 1 : 0
  name                          = "${var.func_name}-func"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  storage_account_name          = azurerm_storage_account.main.name
  storage_account_access_key    = azurerm_storage_account.main.primary_access_key
  service_plan_id               = var.service_plan_id
  app_settings                  = var.app_settings
  functions_extension_version   = var.functions_extension_version
  virtual_network_subnet_id     = var.virtual_network_subnet_id
  public_network_access_enabled = var.func_public_network_access_enabled
  https_only                    = true
  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                              = var.always_on
    application_insights_connection_string = var.application_connection_string
    http2_enabled                          = true
    application_stack {
      dotnet_version              = var.application_stack.dotnet_version
      use_dotnet_isolated_runtime = var.application_stack.use_dotnet_isolated_runtime
      node_version                = var.application_stack.node_version
    }
    dynamic "cors" {
      for_each = var.cors_policy == null ? [] : [var.cors_policy]
      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }

    dynamic "ip_restriction" {
      for_each = var.whitelist_ips == null ? local.default_whitelist_ip : var.whitelist_ips
      content {
        action     = var.whitelist_ips == null ? "Deny" : "Allow"
        priority   = index(var.whitelist_ips == null ? local.default_whitelist_ip : var.whitelist_ips, ip_restriction.value) + 100
        name       = ip_restriction.value.name
        ip_address = ip_restriction.value.source
      }
    }

    scm_use_main_ip_restriction       = false
    scm_ip_restriction_default_action = "Deny"
    ip_restriction_default_action     = "Deny"

    dynamic "scm_ip_restriction" {
      for_each = var.scm_allowed_ips == null ? [] : var.scm_allowed_ips
      content {
        action     = "Allow"
        priority   = index(var.scm_allowed_ips, scm_ip_restriction.value) + 100
        name       = scm_ip_restriction.value.name
        ip_address = scm_ip_restriction.value.source
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = var.scm_allowed_subnet_ids == null ? [] : var.scm_allowed_subnet_ids
      content {
        action                    = "Allow"
        priority                  = index(var.scm_allowed_subnet_ids, scm_ip_restriction.value) + 200
        name                      = scm_ip_restriction.value.name
        virtual_network_subnet_id = scm_ip_restriction.value.subnet_id
      }
    }

  }

  tags = var.tags
}

resource "azurerm_linux_function_app_slot" "slot" {
  count                         = (var.create_slot && var.os_type == "linux") ? 1 : 0
  name                          = "${var.func_name}-slot-func"
  function_app_id               = azurerm_linux_function_app.main[0].id
  storage_account_name          = azurerm_storage_account.main.name
  app_settings                  = var.app_settings
  functions_extension_version   = var.functions_extension_version
  virtual_network_subnet_id     = var.virtual_network_subnet_id
  public_network_access_enabled = var.func_public_network_access_enabled
  https_only                    = true
  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                              = var.always_on
    application_insights_connection_string = var.application_connection_string
    http2_enabled                          = true
    application_stack {
      dotnet_version              = var.application_stack.dotnet_version
      use_dotnet_isolated_runtime = var.application_stack.use_dotnet_isolated_runtime
      node_version                = var.application_stack.node_version
    }
    dynamic "cors" {
      for_each = var.cors_policy == null ? [] : [var.cors_policy]
      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }
    dynamic "ip_restriction" {
      for_each = var.whitelist_ips == null ? local.default_whitelist_ip : var.whitelist_ips
      content {
        action     = var.whitelist_ips == null ? "Deny" : "Allow"
        priority   = index(var.whitelist_ips == null ? local.default_whitelist_ip : var.whitelist_ips, ip_restriction.value) + 100
        name       = ip_restriction.value.name
        ip_address = ip_restriction.value.source
      }
    }

    scm_use_main_ip_restriction       = false
    scm_ip_restriction_default_action = "Deny"
    ip_restriction_default_action     = "Deny"

    dynamic "scm_ip_restriction" {
      for_each = var.scm_allowed_ips == null ? [] : var.scm_allowed_ips
      content {
        action     = "Allow"
        priority   = index(var.scm_allowed_ips, scm_ip_restriction.value) + 100
        name       = scm_ip_restriction.value.name
        ip_address = scm_ip_restriction.value.source
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = var.scm_allowed_subnet_ids == null ? [] : var.scm_allowed_subnet_ids
      content {
        action                    = "Allow"
        priority                  = index(var.scm_allowed_subnet_ids, scm_ip_restriction.value) + 200
        name                      = scm_ip_restriction.value.name
        virtual_network_subnet_id = scm_ip_restriction.value.subnet_id
      }
    }

  }

  tags = var.tags
}

module "custom_alerts" {
  source              = "../custom-query-alert"
  custom_query_alerts = var.custom_query_alerts == null ? local.default_custom_alert : var.custom_query_alerts
  resource_group_name = var.resource_group_name
  location            = var.location
  action_group_id     = var.action_group_id
  scopes              = var.scopes
  tags                = var.tags
}

module "metric_alerts" {
  source              = "../metric-alert"
  metric_alerts       = var.metric_alerts == null ? local.default_metric_alert : var.metric_alerts
  resource_group_name = var.resource_group_name
  scope               = var.os_type == "linux" ? azurerm_linux_function_app.main[0].id : azurerm_windows_function_app.main[0].id
  action_group_id     = var.action_group_id
  tags                = var.tags
}

resource "azurerm_private_endpoint" "func" {
  count               = var.private_endpoint.enabled ? 1 : 0
  name                = "${var.func_name}-private-endpoint"
  resource_group_name = data.azurerm_resource_group.private_vnet_rg[0].name
  location            = data.azurerm_resource_group.private_vnet_rg[0].location
  subnet_id           = data.azurerm_subnet.private_subnet[0].id
  tags                = var.tags
  private_service_connection {
    name                           = "${var.func_name}-private-service-connection"
    private_connection_resource_id = var.os_type == "linux" ? azurerm_linux_function_app.main[0].id : azurerm_windows_function_app.main[0].id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "${var.func_name}-private-dns-zone-group"
    private_dns_zone_ids = [var.private_endpoint.enabled ? data.azurerm_private_dns_zone.func_private_dns_zone[0].id : null]
  }
}
