# SolidaryTech — Infraestrutura AWS (Terraform)

Provisiona a infraestrutura AWS para os 3 microsserviços (`ngo-service`,
`donation-service`, `volunteer-service`), organizada em módulos reutilizáveis.

## O que é criado

| Módulo | Recursos |
|---|---|
| `vpc` | VPC, subnets públicas/privadas (2 AZs), Internet Gateway, NAT Gateway, route tables |
| `security-groups` | SG para nós do EKS, SG do RDS (só libera 5432 a partir do SG dos nós) |
| `eks` | Cluster EKS + IAM roles + managed node group |
| `rds` (x2) | `ngo_db` e `donation_db` — PostgreSQL, Multi-AZ no `donation_db` (hot path) |
| `sqs` | Fila `solidary-donations` + DLQ para eventos que falharem repetidamente |
| `dynamodb` | Tabela `SolidaryTechVolunteers` (partition key `volunteer_id`) |
| `ecr` | Um repositório por serviço (`ngo-service`, `donation-service`, `volunteer-service`), scan-on-push habilitado, lifecycle policy expirando imagens antigas |
| `ssm` | Publica os outputs necessários (endpoints RDS, URL da fila, tabela DynamoDB, URLs do ECR) como parâmetros, para o repositório de GitOps consumir sem acessar o state deste repo |

Todos os recursos recebem as tags `Project`, `Environment`, `CostCenter` e
`ManagedBy`, conforme o requisito de FinOps do hackathon.

## Como rodar localmente

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# edite terraform.tfvars com senhas reais (nunca commitar esse arquivo)

terraform init
terraform plan
terraform apply
```

## Depois do apply

```bash
# configurar kubectl para o novo cluster
aws eks update-kubeconfig --name $(terraform output -raw eks_cluster_name) --region us-east-1

# ver os demais outputs (endpoints do RDS, URL da fila SQS, etc.)
terraform output
```

## Consumindo os outputs do repositório de GitOps (repo separado)

Este repo publica os valores que o pipeline de deploy precisa como
parâmetros no SSM Parameter Store, sob o prefixo `terraform output
ssm_parameter_prefix` (ex: `/solidarytech/production`). No outro repo,
sem precisar de acesso ao state deste:

```bash
aws ssm get-parameter --name /solidarytech/production/rds/ngo-db-endpoint --query Parameter.Value --output text
aws ssm get-parameter --name /solidarytech/production/sqs/queue-url --query Parameter.Value --output text
aws ssm get-parameter --name /solidarytech/production/ecr/donation-service-url --query Parameter.Value --output text
```

## Não incluído neste módulo (próximos passos do hackathon)

- Deploy dos serviços no cluster (manifests Kubernetes / Helm / ArgoCD)
- Pipeline CI/CD (GitHub Actions) com scans de segurança (Trivy/Sonar)
- Stack de observabilidade (Prometheus/Grafana/Loki) e APM
- Módulo de segunda região para o cenário de Disaster Recovery (Warm Standby)
- Backend remoto do Terraform (S3 + lock table) — bloco comentado em `providers.tf`

# GitHub Actions Setup for Terraform

## Required GitHub Secrets

Add these secrets in your GitHub repository settings (Settings → Secrets and variables → Actions → New repository secret):

1. **AWS_ACCESS_KEY_ID** - AWS access key for the devops user
2. **AWS_SECRET_ACCESS_KEY** - AWS secret key for the devops user
3. **NGO_DB_PASSWORD** - Password for ngo_db RDS instance
4. **DONATION_DB_PASSWORD** - Password for donation_db RDS instance

## Workflow Behavior

- **On push to main**: Runs plan and apply
- **On pull request**: Runs plan only
- **Manual trigger**: Can be triggered manually from GitHub Actions tab

## Steps

1. Checkout code
2. Setup Terraform
3. Configure AWS credentials
4. Initialize Terraform (downloads providers, configures backend)
5. Format check (ensures consistent formatting)
6. Plan (shows what will change)
7. Apply (only on main branch pushes)

## S3 Backend Configuration
Ensure `backend.tf` is configured with your S3 bucket name

## Required Variables

Add the following secrets in GitHub repo settings:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- NGO_DB_PASSWORD
- DONATION_DB_PASSWORD