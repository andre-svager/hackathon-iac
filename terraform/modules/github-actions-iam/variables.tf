variable "github_organization" {
  description = "GitHub organization name"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "ecr_repository_names" {
  description = "List of ECR repository names"
  type        = list(string)
}

variable "ssm_parameter_prefix" {
  description = "SSM parameter prefix"
  type        = string
}

variable "secrets_manager_prefix" {
  description = "AWS Secrets Manager secret prefix"
  type        = string
  default     = "solidarytech/production"
}

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default     = {}
}
