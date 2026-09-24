# Note: EKS managed node groups automatically get the cluster's
# AWS-managed primary security group attached to allow control-plane
# <-> node communication — that part needs no manual rules here.
# This SG is for node-to-node traffic and as the "source" identity
# that downstream resources (like RDS) grant access to.

resource "aws_security_group" "eks_nodes" {
  name_prefix = "${var.name}-eks-nodes-"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-eks-nodes-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "eks_nodes_self_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
  description               = "Allow nodes/pods to communicate with each other"
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.name}-rds-"
  description = "Security group for RDS PostgreSQL instances"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-rds-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rds_from_eks_nodes" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = var.eks_cluster_security_group_id # aws_security_group.eks_nodes.id
  description               = "Allow PostgreSQL access only from EKS worker nodes"
}
