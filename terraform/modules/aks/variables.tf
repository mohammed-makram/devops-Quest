variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28.0"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "VM size for the default node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 128
}

variable "enable_auto_scaling" {
  description = "Enable auto scaling for default node pool"
  type        = bool
  default     = true
}

variable "min_count" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum number of nodes"
  type        = number
  default     = 5
}

variable "vnet_subnet_id" {
  description = "Subnet ID for the AKS nodes"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for monitoring"
  type        = string
}

variable "admin_group_object_id" {
  description = "Azure AD admin group object ID"
  type        = string
}

variable "user_pool_vm_size" {
  description = "VM size for the user node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "user_pool_node_count" {
  description = "Number of nodes in the user node pool"
  type        = number
  default     = 2
}

variable "user_pool_enable_auto_scaling" {
  description = "Enable auto scaling for user node pool"
  type        = bool
  default     = true
}

variable "user_pool_min_count" {
  description = "Minimum number of nodes in user pool"
  type        = number
  default     = 1
}

variable "user_pool_max_count" {
  description = "Maximum number of nodes in user pool"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

