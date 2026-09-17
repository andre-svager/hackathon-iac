output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "ngo_db_endpoint" {
  value = module.rds_ngo.endpoint
}

output "donation_db_endpoint" {
  value = module.rds_donation.endpoint
}

output "sqs_queue_url" {
  value = module.sqs.queue_url
}

output "sqs_dlq_url" {
  value = module.sqs.dlq_url
}

output "dynamodb_table_name" {
  value = module.dynamodb.table_name
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "ssm_parameter_prefix" {
  description = "Read parameters from here in the GitOps repo, e.g. aws ssm get-parameter --name <prefix>/rds/ngo-db-endpoint"
  value       = "/${var.project_name}/${var.environment}"
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role for GitOps deployment"
  value       = module.github_actions_iam.role_arn
}

output "github_actions_role_name" {
  description = "Name of the GitHub Actions IAM role"
  value       = module.github_actions_iam.role_name
}

output "github_actions_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = module.github_actions_iam.oidc_provider_arn
}
