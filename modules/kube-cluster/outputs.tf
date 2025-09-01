output "client_certificate" {
  value       = azurerm_kubernetes_cluster.main.kube_config[0].client_certificate
  sensitive   = true
  description = "The client certificate for authenticating to the Kubernetes cluster."
}
output "client_key" {
  value       = azurerm_kubernetes_cluster.main.kube_config[0].client_key
  sensitive   = true
  description = "The client key for authenticating to the Kubernetes cluster."
}
output "cluster_ca_certificate" {
  value       = azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate
  sensitive   = true
  description = "The certificate authority data for the Kubernetes cluster."
}
output "kube_config" {
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
  description = "The kube_config for authenticating to the Kubernetes cluster."
}
output "host" {
  value       = azurerm_kubernetes_cluster.main.kube_config[0].host
  description = "The Kubernetes cluster host."
}
output "kubelet_identity_object_id" {
  value       = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  description = "The object ID of the kubelet identity."
}
output "kubernetes_id" {
  value       = azurerm_kubernetes_cluster.main.id
  description = "The ID of the Kubernetes cluster."
}
