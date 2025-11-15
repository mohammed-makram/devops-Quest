output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "cluster_name" {
  value = module.aks.cluster_name
}

output "cluster_fqdn" {
  value = module.aks.cluster_fqdn
}

output "kube_config" {
  value     = module.aks.kube_config
  sensitive = true
}

output "aks_subnet_id" {
  value = module.network.aks_subnet_id
}

