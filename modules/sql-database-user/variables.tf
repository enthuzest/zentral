variable "host" {
  type        = string
  description = "The host of the SQL Server. Changing this forces a new resource to be created"
}
variable "tenant_id" {
  type        = string
  description = "The tenant ID of the SQL Server."
  default     = "dbce069c-d05f-459d-b139-e3ab046e6bdf"
}
variable "sp_client_id" {
  type        = string
  description = "The client ID of the Service Principal."
}
variable "sp_client_secret" {
  type        = string
  description = "The client secret of the Service Principal."
}
variable "database_name" {
  type        = string
  description = "The name of the database in which to add user/ad group."
}
variable "ad_display_name" {
  type        = string
  description = "The display name of the ad group."
}
variable "ad_object_id" {
  type        = string
  description = "Value of the object id of the ad group"
}
variable "roles" {
  type        = list(string)
  description = "The role to assign to the user/ad group."
}
