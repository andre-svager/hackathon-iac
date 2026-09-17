locals {
  name = "${var.project_name}-${var.environment}"

  # FinOps requirement: every resource carries these tags.
  common_tags = {
    Project     = "SolidaryTech"
    Environment = var.environment
    CostCenter  = var.cost_center
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source = "./modules/vpc"

  name                 = local.name
  cidr_block           = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

module "security_groups" {
  source = "./modules/security-groups"

  name   = local.name
  vpc_id = module.vpc.vpc_id
  tags   = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  name                = local.name
  cluster_version     = var.eks_cluster_version
  subnet_ids          = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  node_subnet_ids     = module.vpc.private_subnet_ids
  node_instance_types = var.eks_node_instance_types
  node_desired_size   = var.eks_node_desired_size
  node_min_size       = var.eks_node_min_size
  node_max_size       = var.eks_node_max_size
  tags                = local.common_tags
}

module "rds_ngo" {
  source = "./modules/rds"

  identifier              = "${local.name}-ngo-db"
  db_name                 = "ngo_db"
  username                = var.ngo_db_username
  password                = var.ngo_db_password
  engine_version          = var.rds_engine_version
  instance_class          = var.rds_instance_class
  allocated_storage       = var.rds_allocated_storage
  subnet_ids              = module.vpc.private_subnet_ids
  vpc_security_group_ids  = [module.security_groups.rds_sg_id]
  backup_retention_period = var.rds_backup_retention_period
  tags                    = merge(local.common_tags, { Service = "ngo-service" })
}

module "rds_donation" {
  source = "./modules/rds"

  identifier              = "${local.name}-donation-db"
  db_name                 = "donation_db"
  username                = var.donation_db_username
  password                = var.donation_db_password
  engine_version          = var.rds_engine_version
  instance_class          = var.rds_instance_class
  allocated_storage       = var.rds_allocated_storage
  subnet_ids              = module.vpc.private_subnet_ids
  vpc_security_group_ids  = [module.security_groups.rds_sg_id]
  backup_retention_period = var.rds_backup_retention_period
  # donation-service is the Hot Path per the hackathon brief — Multi-AZ
  # buys automatic failover instead of relying solely on backups.
  # Disabled for free tier compatibility
  multi_az                = false
  tags                    = merge(local.common_tags, { Service = "donation-service" })
}

module "sqs" {
  source = "./modules/sqs"

  name = var.sqs_queue_name
  tags = merge(local.common_tags, { Service = "donation-service" })
}

module "dynamodb" {
  source = "./modules/dynamodb"

  table_name = var.dynamodb_table_name
  hash_key   = "volunteer_id"
  tags       = merge(local.common_tags, { Service = "volunteer-service" })
}

module "ecr" {
  source = "./modules/ecr"

  repository_names = ["ngo-service", "donation-service", "volunteer-service"]
  tags              = local.common_tags
}

# Publishes the values the separate GitOps repo needs (RDS endpoints, queue
# URL, table name, ECR image URLs) so it never needs access to this repo's
# Terraform state — it just reads these parameters at deploy time.
module "ssm" {
  source = "./modules/ssm"

  prefix = "/${var.project_name}/${var.environment}"
  tags   = local.common_tags

  parameters = {
    "eks/cluster-name"           = module.eks.cluster_name
    "eks/cluster-endpoint"       = module.eks.cluster_endpoint
    "rds/ngo-db-endpoint"        = module.rds_ngo.endpoint
    "rds/donation-db-endpoint"   = module.rds_donation.endpoint
    "sqs/queue-url"              = module.sqs.queue_url
    "sqs/dlq-url"                = module.sqs.dlq_url
    "dynamodb/table-name"        = module.dynamodb.table_name
    "ecr/ngo-service-url"        = module.ecr.repository_urls["ngo-service"]
    "ecr/donation-service-url"   = module.ecr.repository_urls["donation-service"]
    "ecr/volunteer-service-url"  = module.ecr.repository_urls["volunteer-service"]
  }
}

# GitHub Actions IAM role for GitOps deployment
module "github_actions_iam" {
  source = "./modules/github-actions-iam"

  github_organization   = var.github_organization
  github_repository     = var.github_repository
  aws_account_id        = var.aws_account_id
  aws_region            = var.aws_region
  eks_cluster_name      = module.eks.cluster_name
  ecr_repository_names = module.ecr.repository_names
  ssm_parameter_prefix  = "/${var.project_name}/${var.environment}"
  secrets_manager_prefix = "${var.project_name}/${var.environment}"
  tags                  = local.common_tags
}
