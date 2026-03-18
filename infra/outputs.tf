output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "ecr_repository_url" {
  description = "ECR repository URL for the application image"
  value       = aws_ecr_repository.app.repository_url
}

output "ci_server_public_ip" {
  description = "Public IP of the CI tools EC2 server"
  value       = aws_instance.ci_server.public_ip
}

output "ci_server_public_dns" {
  description = "Public DNS of the CI tools EC2 server"
  value       = aws_instance.ci_server.public_dns
}