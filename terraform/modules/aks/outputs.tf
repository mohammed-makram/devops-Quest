output "cluster_id" {
  description = "The ID of the Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "cluster_name" {
  description = "The name of the Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "cluster_fqdn" {
  description = "The FQDN of the Azure Kubernetes Managed Cluster"
  value       = azurerm_kubernetes_cluster.main.fqdn
}

output "cluster_identity" {
  description = "The identity of the Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.main.identity
}

output "kube_config" {
  description = "Raw Kubernetes config to be used by kubectl and other compatible tools"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "host" {
  description = "The Kubernetes cluster server host"
  value       = azurerm_kubernetes_cluster.main.kube_config.0.host
}

output "client_key" {
  description = "Base64 encoded private key used by clients to authenticate to the Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config.0.client_key
  sensitive   = true
}

output "client_certificate" {
  description = "Base64 encoded public certificate used by clients to authenticate to the Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config.0.client_certificate
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64 encoded public CA certificate used as the root of trust for the Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate
  sensitive   = true
}

output "node_resource_group" {
  description = "The resource group name containing the Kubernetes cluster nodes"
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}

