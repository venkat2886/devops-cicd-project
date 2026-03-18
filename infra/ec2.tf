# Fetch latest Ubuntu 22.04 LTS AMI from Canonical (recommended over hardcoding AMI IDs)
data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for CI tools server (Jenkins, SonarQube, Nexus etc.)
resource "aws_security_group" "ci_sg" {
  name        = "${var.project_name}-ci-sg"
  description = "Security group for CI tools server"
  vpc_id      = module.vpc.vpc_id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins
  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SonarQube
  ingress {
    description = "SonarQube"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Nexus Repository Manager
  ingress {
    description = "Nexus"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Optional: Grafana
  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Optional: Prometheus
  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = var.project_name
  }
}

# EC2 Instance for CI tools (Docker-based Jenkins/Sonar/Nexus)
resource "aws_instance" "ci_server" {
  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ci_sg.id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # Increase root volume (Sonar + Nexus needs space)
  root_block_device {
    volume_size = 40
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    apt-get update -y
    apt-get install -y ca-certificates curl gnupg lsb-release git unzip

    # Install Docker
    apt-get install -y docker.io
    systemctl enable docker
    systemctl start docker

    # Allow ubuntu user to run docker without sudo
    usermod -aG docker ubuntu

    # Install Docker Compose v2 (via apt plugin)
    apt-get install -y docker-compose-plugin

    # Basic quality of life tools
    apt-get install -y jq net-tools

    echo "CI tools server ready" > /home/ubuntu/READY.txt
    chown ubuntu:ubuntu /home/ubuntu/READY.txt
  EOF

  tags = {
    Name    = "${var.project_name}-ci-server"
    Project = var.project_name
  }
}