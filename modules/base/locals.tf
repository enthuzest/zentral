locals {
  trusted_ip_ranges = [
    {
      "name"    = "homeIP"
      "network" = "136.23.11.65"
    }
  ]

  nprd_subscription_id = "992dc453-8c7a-44c9-bfe3-991c6f6c6f2c"
  prod_subscription_id = "00000000-0000-0000-0000-000000000000"

  subsription_id = var.environment == "nprd" ? local.nprd_subscription_id : local.prod_subscription_id
  tenant_id     = "78ca5159-6d10-4edb-b73b-9ed9b98fd637"
}
