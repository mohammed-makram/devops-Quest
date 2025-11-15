terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azuread_client_config" "current" {}

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "system"
    node_count          = var.node_count
    vm_size             = var.vm_size
    os_disk_size_gb     = var.os_disk_size_gb
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = var.enable_auto_scaling
    min_count           = var.enable_auto_scaling ? var.min_count : null
    max_count           = var.enable_auto_scaling ? var.max_count : null
    vnet_subnet_id      = var.vnet_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
  }

  oms_agent {
    enabled                    = true
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  azure_policy_enabled = true

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = true
    admin_group_object_ids = [var.admin_group_object_id]
  }

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.user_pool_vm_size
  node_count            = var.user_pool_node_count
  os_disk_size_gb       = var.os_disk_size_gb
  vnet_subnet_id        = var.vnet_subnet_id
  enable_auto_scaling   = var.user_pool_enable_auto_scaling
  min_count             = var.user_pool_enable_auto_scaling ? var.user_pool_min_count : null
  max_count             = var.user_pool_enable_auto_scaling ? var.user_pool_max_count : null

  tags = var.tags
}

