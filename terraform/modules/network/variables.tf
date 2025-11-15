variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "address_space" {
  description = "Address space for the VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_address_prefixes" {
  description = "Address prefixes for AKS subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

