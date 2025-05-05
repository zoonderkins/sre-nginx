# Project Structure

```
├── .github/workflows    # CI/CD pipeline configurations
├── infrastructure       # Terraform code for AWS EKS cluster
├── k8s                  # Kubernetes manifests and Helm charts
└── nginx                # Dockerfile and related files
```

## Components

1. **Infrastructure as Code (Terraform)**
   - AWS EKS Cluster setup
   - VPC with public and private subnets
   - Security groups and IAM policies
   - AWS Load Balancer Controller integration

2. **Containerization (Docker)**
   - Custom Nginx image with "Hello SRE!" text file

3. **Kubernetes Deployment (Helm)**
   - Deployment, Service, Ingress configurations
   - Horizontal Pod Autoscaling
   - Multi-environment support

4. **CI/CD Pipeline (GitHub Actions)**
   - Automated build and deployment
   - Support for different environments

## Setup Instructions

### 1. Infrastructure Deployment

```bash
export AWS_PROFILE=backyard
cd infrastructure/terraform
terraform init
terraform apply
```

### 2. Building and Testing the Docker Image

```bash
cd nginx
docker build -t sre-nginx:latest .
docker run -p 8080:80 sre-nginx:latest
```

- Visit http://localhost:8080/sre.txt in your browser

### 3. Deploying to Kubernetes

```bash
# Configure kubectl to point to your EKS cluster
aws eks update-kubeconfig --region $(terraform output -raw region) --name $(terraform output -raw cluster_name)

# Install the application using Helm
cd k8s/helm
helm install nginx-app ./nginx-app --set environment=production
```

### 4. CI/CD Pipeline

## Environment Support

This project supports multiple environments:

- **Alpha**: Development testing
- **Beta**: Pre-release testing
- **Staging**: Final testing before production
- **Production**: Live environment

To deploy to a specific environment:

```bash
# Using Helm directly
helm install nginx-app ./k8s/helm/nginx-app --set environment=alpha

# Using GitHub Actions
# Trigger the workflow_dispatch event and select the desired environment
```

## Security Considerations

- The EKS cluster uses private subnets for node groups
- IAM policies follow the principle of least privilege
- Network security is enforced via security groups