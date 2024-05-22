variable "eks_cluster_name" {
  type = string
}

variable "assume_role_arn" {
  type = string
}

variable "enable_amp" {
  type    = bool
  default = false
}
