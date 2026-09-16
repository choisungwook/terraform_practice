variable "eks_cluster_name" {
  type = string
}

variable "eks_version" {
  description = "EKS Version"
  type        = string
}

variable "oidc_provider_enabled" {
  description = "OIDC Provider Enabled"
  type        = bool
  default     = true
}

variable "endpoint_private_access" {
  description = "Endpoint Private Access"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Endpoint Public Access"
  type        = bool
}

variable "managed_node_groups" {
  type = map(object({
    node_group_name = string
    instance_types  = list(string)
    capacity_type   = string
    release_version = optional(string)
    ami_id          = optional(string)
    ami_type        = optional(string)
    disk_size       = number
    desired_size    = number
    max_size        = number
    min_size        = number
    user_data       = optional(string)
    labels          = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
  # if you use EKS auto mode, you can set managed_node_groups = {}
  default = {}
}

variable "assume_role_arn" {
  type = string
}

variable "enable_amp" {
  type    = bool
  default = false
}

######################################################################
# VPC
######################################################################

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "VPC public subnets"
  type = map(object({
    cidr = string
    az   = string
    tags = map(string)
  }))
  default = {
    "subnet_a1" = {
      cidr = "10.0.10.0/24",
      az   = "ap-northeast-2a",
      tags = {
        Name = "public-subnet-a1"
      }
    },
    "subnet_b1" = {
      cidr = "10.0.11.0/24",
      az   = "ap-northeast-2c",
      tags = {
        Name = "public-subnet-c1"
      }
    }
  }
}

variable "private_subnets" {
  description = "VPC private_subnets"
  type = map(object({
    cidr = string
    az   = string
    tags = map(string)
  }))
  default = {
    "subnet_a1" = {
      cidr = "10.0.100.0/24",
      az   = "ap-northeast-2a",
      tags = {
        Name = "private-subnet-a1"
      }
    },
    "subnet_b1" = {
      cidr = "10.0.101.0/24",
      az   = "ap-northeast-2c",
      tags = {
        Name = "private-subnet-c1"
      }
    }
  }
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

######################################################################
# EKS control plane
# Ref: https://aws.amazon.com/ko/blogs/tech/eks-advanced-control-plane/
######################################################################

variable "control_plane_scaling_tier" {
  description = "Provisioned control plane tier. standard, tier-xl, tier-2xl, tier-4xl, tier-8xl"
  type        = string
  default     = "standard"
}

variable "kube_api_server_config" {
  description = "kube-apiserver settings. null uses EKS defaults"
  type = object({
    event_ttl = optional(string)
    service_node_port_range = optional(object({
      min_port = number
      max_port = number
    }))
  })
  default = null
}

variable "kube_controller_manager_config" {
  description = "kube-controller-manager settings. null uses EKS defaults. horizontal_pod_autoscaler_sync_period requires tier-xl or higher"
  type = object({
    horizontal_pod_autoscaler_sync_period = optional(string)
    terminated_pod_gc_threshold           = optional(number)
  })
  default = null
}

variable "kube_scheduler_config" {
  description = "kube-scheduler NodeResourcesFit settings. null uses EKS defaults. scoring_strategy_type is LeastAllocated or MostAllocated"
  type = object({
    scoring_strategy_type = string
    scoring_resources = optional(list(object({
      name   = string
      weight = number
    })), [])
  })
  default = null
}
