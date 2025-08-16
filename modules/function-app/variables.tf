variable "function_app_name" {
  description = "The name of the Function App."
  type        = string
}
variable "resource_group_name" {
  description = "The name of the resource group where the Function App will be created."
  type        = string
}
variable "location" {
  description = "The Azure region where the Function App will be created."
  type        = string
}
variable "dotnet_framework_version" {
  description = "value"
  default     = "v6.0"
}
variable "func_version" {
  default = "~4"
}
variable "app_settings" {
  description = "A map of application settings for the Function App."
  type        = map(string)
}
variable "app_service_plan_id" {
  description = "The ID of the App Service Plan to use for the Function App."
  type        = string
}
variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
}
variable "os_type" {
  description = "The operating system type for the Function App (e.g., 'windows' or 'linux')."
  type        = string
}
variable "virtual_network_subnet_id" {
  description = "The ID of the virtual network subnet to which the Function App will be connected."
  type        = string
}
variable "application_insights_connection_string" {
  description = "The connection string for Application Insights."
  type        = string
}
variable "application_stack" {
  description = "The application stack for the Function App (e.g., 'dotnet', 'java', 'node', 'powershell')."
  type = object({
    stack                   = string
    dotnet_version          = optional(string)
    java_version            = optional(string)
    node_version            = optional(string)
    powershell_core_version = optional(string)
  })
}
variable "cors_policy" {
  description = "CORS policy settings for the Function App."
  type = object({
    allowed_origins     = list(string)
    support_credentials = bool
  })

}