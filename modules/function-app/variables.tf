variable "func_name" {
  description = "The name of the function app"
  type        = string
}
variable "resource_group_name" {
  description = "The name of the resource group in which to create the function app"
  type        = string
}
variable "location" {
  description = "The location/region where the function app will be created"
  type        = string
}
variable "service_plan_id" {
  description = "The ID of the App Service Plan within which to create the function app"
  type        = string
}
variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
}
variable "app_settings" {
  description = "A mapping of app settings to assign to the function app"
  type        = map(string)
}
variable "storage_account_network_rules" {
  type = object({
    default_action             = string
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  description = "A mapping of network rules to apply to the storage account"
  default = {
    default_action = "Deny"
  }
}
variable "create_slot" {
  description = "Whether or not to create a deployment slot"
  type        = bool
  default     = false
}
variable "functions_extension_version" {
  description = "The version of the Azure Functions extension to use"
  type        = string
  default     = "~4"
}
variable "application_connection_string" {
  description = "The Application Connection String for the function app"
  type        = string
}
variable "cors_policy" {
  description = "A mapping of CORS policy settings"
  type = object({
    allowed_origins     = list(string)
    support_credentials = bool
  })
  default = null
}
variable "private_endpoint" {
  description = "The details of the private endpoint to create"
  type = object({
    enabled                              = optional(bool, false)
    vnet_resource_group_name             = optional(string, null)
    vnet_name                            = optional(string, null)
    vnet_subnet_name                     = optional(string, null)
    private_dns_zone_resource_group_name = optional(string, null)
  })
  default = {}
}
variable "os_type" {
  description = "The operating system type of the function app"
  type        = string
  validation {
    condition     = var.os_type == "windows" || var.os_type == "linux"
    error_message = "os_type must be either 'windows' or 'linux'"
  }
}
variable "always_on" {
  description = "Should the function app be always on"
  type        = bool
  default     = true
}
variable "whitelist_ips" {
  description = "list of whitelisted IPs"
  type = list(object({
    name   = string
    source = string
  }))
  default = null
}
variable "custom_query_alerts" {
  type = map(object({
    alert_name              = string
    description             = string
    query                   = string
    severity                = string
    frequency               = string
    time_window             = string
    operator                = string
    threshold               = number
    time_aggregation_method = string
    metric_measure_column   = optional(string, null)
  }))
  description = "list of metric alerts"
  default     = null
}
variable "metric_alerts" {
  type = map(object({
    alert_name       = string
    description      = string
    metric_namespace = string
    metric_name      = string
    aggregation      = string
    operator         = string
    threshold        = number
    severity         = number
    dimension = object({
      name     = string
      operator = string
      values   = list(string)
    })
  }))
  description = "list of metric alerts"
  default     = null
}
variable "action_group_id" {
  type        = string
  description = "The ID of the action group to associate with the metric alert"
}
variable "scopes" {
  type        = string
  description = "The ID of the data source to associate with the metric alert"
}
variable "application_stack" {
  type = object({
    dotnet_version              = optional(string, null)
    use_dotnet_isolated_runtime = optional(bool, null)
    node_version                = optional(string, null)
  })
  default = {
    dotnet_version              = "8.0"
    use_dotnet_isolated_runtime = true
    node_version                = null
  }
  description = "The application stack to use for the function app"
}
variable "virtual_network_subnet_id" {
  type        = string
  description = "The ID of the subnet within the virtual network to integrate with"
  default     = null
}
variable "shared_access_key_enabled" {
  type        = bool
  description = "Should the storage account shared access key be enabled"
  default     = true
}
variable "storage_queue_names" {
  type        = list(string)
  description = "A list of storage queues to create"
  default     = null
}
variable "func_public_network_access_enabled" {
  description = "Whether to allow public network access"
  type        = bool
  default     = false
}
variable "scm_allowed_ips" {
  description = "list of scm whitelisted IPs"
  type = list(object({
    name   = string
    source = string
  }))
  default = null
}
variable "scm_allowed_subnet_ids" {
  description = "list of scm whitelisted subnet IDs"
  type = list(object({
    name      = string
    subnet_id = string
  }))
  default = null
}
variable "public_network_access_enabled" {
  description = "Whether to allow public network access to the storage account"
  type        = bool
  default     = null
}
