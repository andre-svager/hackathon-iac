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
