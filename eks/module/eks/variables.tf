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

variable "endpoint_private_access" {
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
    user_data       = optional(string)
  }))
}

variable "aws_auth_admin_roles" {
  description = "eks admin IAM roles"
  type        = list(string)
  default     = []
}

variable "eks_addons" {
  type = list(object({
    name                 = string
    version              = string
    configuration_values = string
    before_compute       = optional(bool, false)
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

variable "enable_amp" {
  type    = bool
  default = false
}

variable "cluster_ip_family" {
  description = "The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. You can only specify an IP family when you create a cluster, changing this value will force a new cluster to be created"
  type        = string
  default     = "ipv4"
}

variable "cluster_service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks"
  type        = string
  default     = null
}

variable "cluster_service_ipv6_cidr" {
  description = "The CIDR block to assign Kubernetes pod and service IP addresses from if `ipv6` was specified when the cluster was created. Kubernetes assigns service addresses from the unique local address range (fc00::/7) because you can't specify a custom IPv6 CIDR block when you create the cluster"
  type        = string
  default     = null
}

######################################################################
# EKS auto mode
# When using EKS Auto Mode compute_config.enabled, kubernetes_network_config.elastic_load_balancing.enabled, and storage_config.block_storage.enabled
# must *ALL be set to true.
# Likewise for disabling EKS Auto Mode, all three arguments must be set to false.
######################################################################

variable "auto_mode_enabled" {
  description = "Enable EKS Auto Mode"
  type        = bool
  default     = false
}

variable "cluster_compute_config" {
  description = "Configuration block for the cluster compute configuration"
  type        = any
  default     = {}
}
