variable "eks-name" {
  description = "eks cluster name"
  type        = string
}

variable "eks_version" {
  description = "eks version"
  type        = string
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
