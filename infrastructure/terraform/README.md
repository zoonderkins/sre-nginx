# Terraform AWS EKS Infrastructure

This directory contains Terraform configurations to deploy an EKS Kubernetes cluster on AWS.

## Components

* VPC with public and private subnets across multiple availability zones
* EKS cluster with managed node groups
* AWS Load Balancer Controller integration
* Security groups and IAM roles

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Configure AWS credentials:
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
```

3. Plan the deployment:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

5. After successful deployment, configure kubectl:
```bash
aws eks update-kubeconfig --region $(terraform output -raw region) --name $(terraform output -raw cluster_name)
```

## Environment Variables

You can customize the deployment by setting the following variables:

* `region`: AWS region (default: us-west-2)
* `cluster_name`: Name of the EKS cluster (default: gamania-eks-cluster)
* `kubernetes_version`: Kubernetes version (default: 1.26)
* `environment`: Environment name (default: production)
* `vpc_cidr`: CIDR block for VPC (default: 10.0.0.0/16)
* `node_group_min_size`: Minimum node count (default: 2)
* `node_group_max_size`: Maximum node count (default: 5)
* `node_group_desired_size`: Desired node count (default: 3)

## Multi-Environment Support

This configuration supports multiple environments (alpha, beta, staging, production). To deploy to a specific environment, use:

```bash
terraform apply -var="environment=alpha"
```

## Cleanup

To destroy all resources:
```bash
terraform destroy
``` 