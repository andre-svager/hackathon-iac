# AWS Free Tier Limitations & Costs

## Free Tier Compatible Resources

The following resources are configured for AWS Free Tier eligibility:

### EC2 (EKS Nodes)
- **Instance Type**: `t3.micro`
- **Free Tier**: 750 hours/month per month for 12 months
- **Current Config**: 2 nodes (desired), 1-4 (min-max)
- **Estimated Cost**: $0 if within 750 hours/month, otherwise ~$8.47/month per instance

### RDS PostgreSQL
- **Instance Type**: `db.t3.micro`
- **Free Tier**: 750 hours/month per month for 12 months
- **Current Config**: 2 instances (ngo-db, donation-db)
- **Estimated Cost**: $0 if within 750 hours/month, otherwise ~$15/month per instance
- **Storage**: 20 GB each (not free tier - ~$0.115/GB/month = ~$2.30/month each)

## Non-Free Tier Resources (Monthly Costs)

These resources will incur costs even on free tier:

### EKS Cluster
- **Cost**: ~$0.10/hour = **~$72/month**
- **Note**: EKS control plane is never free tier

### NAT Gateway
- **Cost**: ~$0.045/hour = **~$32.40/month**
- **Data Processing**: ~$0.045/GB
- **Note**: Required for private subnets to access internet

### Elastic IP (EIP)
- **Cost**: ~$0.005/hour = **~$3.60/month** when attached to NAT Gateway
- **Note**: Free only when attached to running EC2 instance

### DynamoDB
- **Pricing Model**: Pay-per-request (on-demand)
- **Free Tier**: 25 GB storage, 200 WCUs, 200 RCUs
- **Estimated Cost**: Minimal for hackathon usage

### SQS
- **Pricing Model**: Per request
- **Free Tier**: 1 million requests/month
- **Estimated Cost**: Minimal for hackathon usage

### ECR
- **Pricing Model**: Per GB-month storage
- **Free Tier**: 500 GB-month storage
- **Estimated Cost**: Minimal for hackathon usage

### SSM Parameter Store
- **Pricing Model**: Per API call
- **Free Tier**: 10,000 API calls/month (Standard tier)
- **Estimated Cost**: Minimal for hackathon usage

## Estimated Monthly Cost (Full Stack)

With current configuration:
- EKS Cluster: $72
- NAT Gateway: $32.40
- EIP: $3.60
- RDS Storage (40 GB): ~$4.60
- **Total**: ~$112.60/month

## Free Tier Optimization Options

To reduce costs, consider:

### Option 1: Remove NAT Gateway (Saves ~$36/month)
- Use only public subnets
- Remove private subnets
- Security trade-off: resources directly accessible from internet

### Option 2: Use Fargate instead of EKS Nodes (Saves ~$17/month)
- Remove EC2 node group
- Use AWS Fargate for pod execution
- Fargate costs: ~$0.0405/vCPU-hour + $0.0045/GB-hour
- Still pays EKS cluster fee ($72/month)

### Option 3: Use ECS instead of EKS (Saves ~$72/month)
- Remove EKS cluster
- Use ECS Fargate
- No cluster control plane fee
- Trade-off: No Kubernetes, uses Docker Compose/ECS task definitions

### Option 4: Single AZ Deployment (Saves minimal)
- Already done: Multi-AZ disabled for RDS
- NAT Gateway: Could use 1 NAT instead of 1 per AZ (already configured)

## Configuration Changes Made

1. **EKS Version**: Changed from 1.29 to 1.27 (free tier compatibility)
2. **RDS Backup Retention**: Set to 0 days (free tier max: 0-1 days)
3. **RDS Multi-AZ**: Disabled (not free tier compatible)
4. **EKS Node Type**: Changed from t3.medium to t3.micro (free tier eligible)

## Important Notes

- Free tier is available for the first 12 months only
- After 12 months, all resources incur full costs
- Monitor costs using AWS Cost Explorer
- Set up billing alerts to avoid unexpected charges
- Delete resources when not in use to minimize costs
