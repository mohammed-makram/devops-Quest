variable "admin_group_object_id" {
  description = "Azure AD admin group object ID for AKS RBAC"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

