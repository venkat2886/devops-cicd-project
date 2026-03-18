variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix for all resources"
  type        = string
  default     = "devops-cicd"
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "devops-eks"
}

variable "instance_type" {
  description = "EC2 instance type for CI tools server"
  type        = string
  default     = "t3.medium"
}