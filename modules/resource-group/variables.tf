variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}
variable "location" {
  description = "The location of the resource group"
  type        = string
  validation {
    condition     = contains(["australiasoutheast", "australiaeast"], var.location)
    error_message = "Invalid location. Location can only be australiasoutheast and australiaeast"
  }
}
variable "contributor_ad_group_names" {
  description = "A list of Azure AD group names to assign the Contributor role to"
  type        = list(string)
  default     = []
}
variable "reader_ad_group_names" {
  description = "A list of Azure AD group names to assign the Reader role to"
  type        = list(string)
  default     = []
}
variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
}