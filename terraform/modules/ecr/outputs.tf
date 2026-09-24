output "repository_names" {
  value = var.repository_names
}

output "repository_urls" {
  value = { for name, repo in aws_ecr_repository.this : name => repo.repository_url }
}
