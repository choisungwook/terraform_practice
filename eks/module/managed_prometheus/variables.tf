variable "eks_cluster_name" {
  description = "eks cluster name"
  type        = string
}

variable "eks_cluster_arn" {
  description = "eks cluster arn"
  type        = string
}

variable "scrap_configuration_content" {
  description = "scrap_configuration_content"
  type        = string
}

variable "private_subnets_ids" {
  description = "private subnets ids"
  type        = list(string)
}
