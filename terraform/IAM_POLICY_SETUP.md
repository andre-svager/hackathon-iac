# IAM Policy Setup for Terraform Deployment

## Problem
The `devops` IAM user (`arn:aws:iam::621996700064:user/devops`) lacks permissions to create AWS resources required by the Terraform configuration.

## Required Permissions

- **DynamoDB**: `dynamodb:CreateTable`
- **ECR**: `ecr:CreateRepository`
- **IAM**: `iam:CreateRole`, `iam:AttachRolePolicy`, `iam:PassRole`
- **SQS**: `sqs:CreateQueue`
- **EC2/VPC**: `ec2:CreateVpc`, `ec2:AllocateAddress`, and related VPC networking permissions
- **EKS**: `eks:CreateCluster`, `eks:CreateNodegroup`
- **RDS**: `rds:CreateDBInstance`, `rds:CreateDBSubnetGroup`
- **SSM**: `ssm:PutParameter`
- **Security Groups**: EC2 security group management
- **Tagging**: Resource tagging permissions
- **Terraform State**: S3 access for state management (if using remote state)
- **KMS**: Encryption/decryption for RDS and other encrypted resources

## Solution

### Option 1: Administrator Creates Custom Policy (Recommended)

Since the `devops` user lacks `iam:CreatePolicy` permissions, an administrator with IAM permissions must create and attach the policy.

**Ask your AWS administrator to run:**

1. **Create the IAM policy** from the provided JSON file:

```bash
aws iam create-policy \
  --policy-name SolidaryTechTerraformPolicy \
  --policy-document file://iam-policy-for-devops.json
```

2. **Attach the policy to the devops user**:

```bash
aws iam attach-user-policy \
  --user-name devops \
  --policy-arn arn:aws:iam::621996700064:policy/SolidaryTechTerraformPolicy
```

### Option 2: Attach AWS Managed Policies (Quickest Fix)

**Ask your AWS administrator to attach** one of these managed policies to the devops user:

```bash
# AdministratorAccess (NOT recommended for production - too broad)
aws iam attach-user-policy \
  --user-name devops \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# OR PowerUserAccess (still broad but better)
aws iam attach-user-policy \
  --user-name devops \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

**Note:** The devops user cannot attach policies to themselves due to lack of `iam:AttachUserPolicy` permissions. An administrator must perform this action.

### Option 3: Update Existing Inline Policy

If the devops user already has an inline policy, update it with the permissions from `iam-policy-for-devops.json`.

## Verification

After attaching the policy, verify the permissions:

```bash
aws iam list-attached-user-policies --user-name devops
```

## Re-run Terraform

Once the policy is attached, re-run Terraform:

```bash
terraform plan
terraform apply
```

## Security Considerations

- The custom policy is scoped to account `621996700064` and region `us-east-1`
- For production environments, consider using IAM roles with AssumeRole instead of long-lived user credentials
- Regularly review and audit the permissions granted to the devops user
- Consider implementing IAM Access Analyzer to detect unused permissions

## Cleanup

If you need to remove the policy later:

```bash
aws iam detach-user-policy \
  --user-name devops \
  --policy-arn arn:aws:iam::621996700064:policy/SolidaryTechTerraformPolicy

aws iam delete-policy \
  --policy-arn arn:aws:iam::621996700064:policy/SolidaryTechTerraformPolicy
```
