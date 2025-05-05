# GitHub OIDC Provider
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Add variable for GitHub repository
variable "github_repository" {
  description = "GitHub repository in format org/repo"
  type        = string
  default     = "zoonderkins/sre-nginx"
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "${var.cluster_name}-github-actions-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub": "repo:${var.github_repository}:*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# EKS Cluster full access policy
resource "aws_iam_policy" "github_actions_eks_access" {
  name        = "${var.cluster_name}-github-actions-eks-access"
  description = "Policy allowing GitHub Actions to access and manage EKS cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:*",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeRouteTables",
          "ec2:DescribeVpcs",
          "iam:GetRole",
          "iam:ListAttachedRolePolicies",
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_eks_access" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_eks_access.arn
}

# ECR Policy
resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# EKS Cluster Policy (AWS managed)
resource "aws_iam_role_policy_attachment" "github_actions_eks" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Add EKS service policy
resource "aws_iam_role_policy_attachment" "github_actions_eks_service" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# More expanded policy for kubectl operations
resource "aws_iam_policy" "github_actions_kubectl" {
  name        = "${var.cluster_name}-github-actions-kubectl-policy"
  description = "Policy allowing GitHub Actions to use kubectl with EKS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:UpdateClusterConfig",
          "eks:AccessKubernetesApi",
          "eks:ListNodegroups",
          "eks:DescribeNodegroup",
          "eks:ListFargateProfiles",
          "eks:DescribeFargateProfile"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_kubectl" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_kubectl.arn
}

# Add policy for Load Balancer operations
resource "aws_iam_policy" "github_actions_alb" {
  name        = "${var.cluster_name}-github-actions-alb-policy"
  description = "Policy allowing GitHub Actions to manage Load Balancers"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:*",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeRouteTables",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_alb" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_alb.arn
}
output "github_actions_role_arn" {
  description = "ARN of IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
} 