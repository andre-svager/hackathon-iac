variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "eks_cluster_security_group_id" {
  description = "The EKS cluster's auto-generated security group ID (nodes are members of this by default)"
  type        = string
}