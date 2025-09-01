variable "database_name" {
  description = "The name of the database"
  type        = string
}
variable "server_id" {
  description = "The ID of the SQL Server"
  type        = string
}
variable "max_size_gb" {
  description = "The maximum size of the database in gigabytes"
  type        = number
  default     = 1
}
variable "sku_name" {
  description = "The SKU name of the database"
  type        = string
  default     = "Basic"
}
variable "short_term_retention_days" {
  description = "The number of days to retain backups for"
  type        = number
  default     = 7
}
variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
}
variable "elastic_pool_id" {
  description = "The ID of the Elastic Pool to which to assign the database"
  type        = string
  default     = null
}
variable "failover_group" {
  description = "The details for setting the sql failover group"
  type = object({
    enabled             = optional(bool, false)
    failover_group_name = optional(string)
    secondary_server_id = optional(string)
  })
  default = {}
}
