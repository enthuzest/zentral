variable "kube_name" {
  type        = string
  description = "The name of the Managed Kubernetes Cluster to create."
}
variable "location" {
  type        = string
  description = "The location/region where the Managed Kubernetes Cluster should be created."
}
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Managed Kubernetes Cluster."
}
variable "vnet_subnet_id" {
  type        = string
  description = "The ID of the Subnet where the Kubernetes Cluster should be deployed."
}
variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources."
}
variable "node_pool" {
  type = list(object({
    pool_name  = string
    vm_size    = string
    node_count = number
    os_type    = string
    os_sku     = string
    max_pods   = number
  }))
}
variable "default_node_pool" {
  type = object({
    pool_name       = string
    vm_size         = string
    os_disk_size_gb = number
    node_count      = number
    max_pods        = number
  })
}