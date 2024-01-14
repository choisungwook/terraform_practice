variable "eks_cluster_name" {
  description = "eks cluster name"
  type        = string
}

variable "eks_version" {
  description = "eks version"
  type        = string
}

variable "oidc_provider_enabled" {
  description = "oidc provider enabled"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "vpc id"
  type        = string
}

variable "private_subnets_ids" {
  description = "private subnets ids"
  type        = list(string)
}

variable "endpoint_prviate_access" {
  description = "endpoint for prviate access"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "endpoint for public for access"
  type        = bool
  default     = true
}

variable "managed_node_groups" {
  type = map(object({
    node_group_name = string
    instance_types  = list(string)
    capacity_type   = string
    release_version = string
    disk_size       = number
    desired_size    = number
    max_size        = number
    min_size        = number
  }))
}

variable "aws_auth_admin_roles" {
  description = "eks admin in aws auth configmap"
  type        = list(string)
  default     = []
}

variable "eks_addons" {
  type = list(object({
    name                 = string
    version              = string
    configuration_values = string
  }))
  default = []
}

variable "karpenter_enabled" {
  description = "karpenter enabled"
  type        = bool
  default     = false
}

variable "alb_controller_enabled" {
  description = "alb controller enabled"
  type        = bool
  default     = false
}

variable "external_dns_enabled" {
  description = "external_dns_enabled enabled"
  type        = bool
  default     = false
}

