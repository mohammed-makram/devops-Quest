terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "remote" {
    organization = "your-org"
    workspaces {
      name = "dev-voting-app"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  environment = "dev"
  location    = "East US"
  common_tags = {
    Environment = local.environment
    Project     = "voting-app"
    ManagedBy   = "Terraform"
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.environment}-voting-app"
  location = local.location
  tags     = local.common_tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${local.environment}-voting-app"
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

# Network Module
module "network" {
  source              = "../../modules/network"
  resource_group_name = azurerm_resource_group.main.name
  environment         = local.environment
  location            = local.location
  tags                = local.common_tags
}

# AKS Module
module "aks" {
  source                       = "../../modules/aks"
  resource_group_name          = azurerm_resource_group.main.name
  cluster_name                 = "aks-${local.environment}-voting-app"
  dns_prefix                   = "aks-${local.environment}-voting"
  kubernetes_version           = "1.28.0"
  node_count                   = 2
  vm_size                      = "Standard_D2s_v3"
  min_count                    = 1
  max_count                    = 3
  enable_auto_scaling          = true
  vnet_subnet_id               = module.network.aks_subnet_id
  log_analytics_workspace_id   = azurerm_log_analytics_workspace.main.id
  admin_group_object_id        = var.admin_group_object_id
  user_pool_vm_size            = "Standard_D2s_v3"
  user_pool_node_count         = 1
  user_pool_min_count          = 1
  user_pool_max_count          = 5
  user_pool_enable_auto_scaling = true
  tags                         = local.common_tags
}

