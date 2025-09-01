resource "azurerm_kubernetes_cluster" "main" {
  name                              = var.kube_name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  dns_prefix                        = var.kube_name
  role_based_access_control_enabled = true
  automatic_upgrade_channel         = "patch"
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  node_resource_group               = "${var.kube_name}-nodes-rg"
  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Saturday"
    start_time  = "08:00"
    utc_offset  = "+10:00"
  }
  network_profile {
    network_plugin = "azure"
  }

  dynamic "default_node_pool" {
    for_each = var.default_node_pool == null ? [] : [var.default_node_pool]
    content {
      node_count      = default_node_pool.value.node_count
      name            = "linux"
      vm_size         = default_node_pool.value.vm_size
      os_disk_size_gb = default_node_pool.value.os_disk_size_gb
      vnet_subnet_id  = var.vnet_subnet_id
      max_pods        = default_node_pool.value.node_count * default_node_pool.value.max_pods
      upgrade_settings {
        max_surge = "10%"
      }
      tags = var.tags
    }

  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "pool" {
  for_each              = { for np in var.node_pool : np.pool_name => np }
  name                  = each.value.pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  os_type               = each.value.os_type
  os_sku                = each.value.os_sku
  vnet_subnet_id        = var.vnet_subnet_id
  max_pods              = each.value.node_count * each.value.max_pods
  tags                  = var.tags
}
