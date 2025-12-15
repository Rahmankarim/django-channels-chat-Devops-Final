# Terraform Infrastructure Setup Guide

This directory contains Terraform configuration for provisioning AWS infrastructure for the Django Channels Chat application.

## Architecture Overview

The infrastructure includes:

- **VPC**: Multi-AZ VPC with public, private, and database subnets
- **EKS**: Managed Kubernetes cluster with auto-scaling node groups
- **RDS**: PostgreSQL database with automated backups
- **ElastiCache**: Redis cluster for WebSocket channel layer
- **Security Groups**: Properly configured security groups for each component
- **KMS**: Encryption keys for EKS and RDS

## Prerequisites

1. **AWS CLI** configured with appropriate credentials

   ```bash
   aws configure
   ```

2. **Terraform** installed (version >= 1.0)

   ```bash
   terraform version
   ```

3. **kubectl** for EKS management
   ```bash
   kubectl version --client
   ```

## Setup Instructions

### 1. Initialize Terraform

```bash
cd infra
terraform init
```

### 2. Create terraform.tfvars

Copy the example file and update with your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific configuration:

```hcl
aws_region = "us-east-1"
environment = "dev"
db_password = "your-secure-password-here"
# ... other variables
```

### 3. Plan Infrastructure

Review what will be created:

```bash
terraform plan
```

### 4. Apply Infrastructure

Create the infrastructure:

```bash
terraform apply
```

This will provision:

- VPC with networking components (~5 minutes)
- EKS cluster (~15-20 minutes)
- RDS PostgreSQL instance (~10 minutes)
- ElastiCache Redis cluster (~5 minutes)

**Total time: ~30-40 minutes**

### 5. Configure kubectl

After EKS cluster is created, configure kubectl:

```bash
aws eks update-kubeconfig --region us-east-1 --name django-chat-cluster
```

Verify connection:

```bash
kubectl get nodes
```

### 6. View Outputs

Display important information:

```bash
terraform output
```

Key outputs:

- `eks_cluster_endpoint`: EKS API server endpoint
- `rds_endpoint`: PostgreSQL database endpoint
- `redis_endpoint`: Redis cache endpoint
- `configure_kubectl`: Command to configure kubectl

## Infrastructure Components

### VPC (vpc.tf)

- CIDR: 10.0.0.0/16
- Public subnets: For load balancers
- Private subnets: For EKS nodes
- Database subnets: For RDS and ElastiCache
- NAT Gateway: For internet access from private subnets

### EKS Cluster (eks.tf)

- Kubernetes version: 1.28
- Node group with t3.medium instances
- Auto-scaling: 1-4 nodes
- Managed addons: CoreDNS, kube-proxy, VPC-CNI, EBS CSI Driver

### RDS PostgreSQL (rds.tf)

- Engine: PostgreSQL 15.4
- Instance: db.t3.micro (upgradeable)
- Storage: 20GB with auto-scaling to 100GB
- Automated backups: 3 days retention (7 for prod)
- Enhanced monitoring enabled

### ElastiCache Redis (elasticache.tf)

- Engine: Redis 7.0
- Node: cache.t3.micro
- CloudWatch logging enabled
- Snapshot retention: 1 day (5 for prod)

## Cost Estimation

Approximate monthly costs (us-east-1, as of 2024):

| Resource          | Configuration  | Monthly Cost    |
| ----------------- | -------------- | --------------- |
| EKS Cluster       | Control plane  | $73             |
| EC2 (EKS nodes)   | 2x t3.medium   | ~$60            |
| RDS PostgreSQL    | db.t3.micro    | ~$15            |
| ElastiCache Redis | cache.t3.micro | ~$12            |
| NAT Gateway       | 1 gateway      | ~$32            |
| Data Transfer     | Estimated      | ~$10            |
| **Total**         |                | **~$200/month** |

> **Note**: Costs vary based on usage, region, and configuration. Use AWS Cost Calculator for precise estimates.

## Cleanup

To destroy all infrastructure:

```bash
terraform destroy
```

**Warning**: This will delete:

- All resources
- Database (unless deletion protection is enabled)
- All data in RDS and ElastiCache

Take a final snapshot before destroying production infrastructure.

## State Management

### Local State (Default)

State file is stored locally in `terraform.tfstate`.

### Remote State (Recommended for Production)

Uncomment the backend configuration in `main.tf`:

```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "django-channels-chat/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-state-lock"
}
```

Create the S3 bucket and DynamoDB table first:

```bash
aws s3 mb s3://your-terraform-state-bucket
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

## Security Best Practices

1. **Never commit terraform.tfvars** - Add to `.gitignore`
2. **Use AWS Secrets Manager** for sensitive values in production
3. **Restrict CIDR blocks** - Don't use 0.0.0.0/0 in production
4. **Enable encryption** - All data at rest and in transit
5. **Enable MFA** for AWS account
6. **Use IAM roles** instead of access keys where possible
7. **Regular security audits** with AWS Config and Security Hub

## Troubleshooting

### EKS Cluster Not Accessible

```bash
aws eks update-kubeconfig --region us-east-1 --name django-chat-cluster
kubectl cluster-info
```

### RDS Connection Issues

- Check security group rules
- Verify database is in "available" state
- Test from within VPC (EC2 or EKS pod)

### Terraform State Locked

```bash
terraform force-unlock <lock-id>
```

### Cost Concerns

- Use t3 instances instead of t2
- Enable auto-scaling
- Use Spot instances for dev/test
- Implement proper resource tagging

## Next Steps

After infrastructure is provisioned:

1. Deploy Kubernetes manifests (see `../k8s/`)
2. Configure secrets in Kubernetes
3. Set up monitoring (Prometheus/Grafana)
4. Configure CI/CD pipeline
5. Set up DNS and SSL certificates

## Support

For issues:

1. Check AWS service health dashboard
2. Review CloudWatch logs
3. Run `terraform plan` to check drift
4. Consult AWS documentation
