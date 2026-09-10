variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name, used in tagging and resource naming"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name, used as a naming prefix"
  type        = string
  default     = "solidarytech"
}

variable "cost_center" {
  description = "FinOps cost center tag"
  type        = string
  default     = "NGO-Core"
}

# ---------- Networking ----------

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones to spread subnets across"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets, one per AZ"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets, one per AZ"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# ---------- EKS ----------

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS control plane"
  type        = string
  default     = "1.31"
}

variable "eks_node_instance_types" {
  description = "EC2 instance types for the EKS managed node group (free tier: t3.micro)"
  type        = list(string)
  default     = ["t3.micro"]
}

variable "eks_node_desired_size" {
  type    = number
  default = 2
}

variable "eks_node_min_size" {
  type    = number
  default = 1
}

variable "eks_node_max_size" {
  type    = number
  default = 4
}

# ---------- RDS ----------

variable "ngo_db_username" {
  type    = string
  default = "ngo_admin"
}

variable "ngo_db_password" {
  description = "Master password for the ngo_db RDS instance. Set via terraform.tfvars (gitignored) or TF_VAR_ngo_db_password."
  type        = string
  sensitive   = true
}

variable "donation_db_username" {
  type    = string
  default = "donation_admin"
}

variable "donation_db_password" {
  description = "Master password for the donation_db RDS instance. Set via terraform.tfvars (gitignored) or TF_VAR_donation_db_password."
  type        = string
  sensitive   = true
}

variable "rds_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "rds_backup_retention_period" {
  description = "Backup retention period in days (free tier max: 0-1)"
  type        = number
  default     = 0
}

variable "rds_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.7"
}

# ---------- SQS ----------

variable "sqs_queue_name" {
  type    = string
  default = "solidary-donations"
}

# ---------- DynamoDB ----------

variable "dynamodb_table_name" {
  type    = string
  default = "SolidaryTechVolunteers"
}
