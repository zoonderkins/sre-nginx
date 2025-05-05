# IAM Role for Load Balancer Controller
module "lb_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "5.30.0"

  role_name = "${var.cluster_name}_eks_lb"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Role ARN for the Load Balancer Controller
output "lb_controller_role_arn" {
  description = "ARN of IAM role for AWS Load Balancer Controller"
  value       = module.lb_role.iam_role_arn
} 