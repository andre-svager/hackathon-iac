variable "name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "subnet_ids" {
  description = "Subnets for the EKS control plane ENIs (public + private)"
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "Subnets for worker nodes (private only, recommended)"
  type        = list(string)
}

variable "node_instance_types" {
  type = list(string)
}

variable "node_desired_size" {
  type = number
}

variable "node_min_size" {
  type = number
}

variable "node_max_size" {
  type = number
}

variable "tags" {
  type    = map(string)
  default = {}
}
