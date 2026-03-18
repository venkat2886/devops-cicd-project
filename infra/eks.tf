module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.3"

  cluster_name    = var.eks_cluster_name
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Public endpoint is easiest for sandbox/laptop access
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Enable IAM Roles for Service Accounts (useful later for ALB controller, external-dns, etc.)
  enable_irsa = true

  # Managed Node Group (CPU nodes)
  eks_managed_node_groups = {
    default = {
      name           = "${var.project_name}-ng"
      instance_types = ["t3.medium"]

      desired_size = 2
      min_size     = 1
      max_size     = 3

      # Use private subnets for nodes (recommended)
      subnet_ids = module.vpc.private_subnets
    }
  }

  tags = {
    Project = var.project_name
  }
}