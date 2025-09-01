variable "agent_count" {
  type        = number
  description = "The number of agents to deploy"
}
variable "agent_name" {
  type        = string
  description = "The name of the agent"
}
variable "namespace" {
  type        = string
  description = "The namespace of the agent"
}
variable "container_image" {
  type        = string
  description = "The container image to deploy"
}
variable "azp_url" {
  type        = string
  description = "The Azure DevOps URL"
}
variable "azp_pool" {
  type        = string
  description = "The Azure DevOps pool"
}
variable "azp_token" {
  type        = string
  description = "The Azure DevOps token"
}
variable "node_name" {
  type        = string
  description = "The node name"
}
variable "env" {
  type        = list(map(string))
  description = "The environment variables to set"
  default     = []
}
