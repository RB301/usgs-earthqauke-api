# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# AWS Availability Zones
data "aws_availability_zones" "available" {}

# VPC for EKS Cluster
resource "aws_vpc" "prima_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "prima-vpc"
  }
}

# Subnets for EKS Cluster
resource "aws_subnet" "prima_subnet" {
  count             = 2
  vpc_id            = aws_vpc.prima_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.prima_vpc.cidr_block, var.subnet_cidr_mask, count.index + 1)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "prima-subnet-${count.index}"
  }
}

# Security Group for EKS Control Plane
resource "aws_security_group" "prima_eks_control_plane_sg" {
  name_prefix = "prima-eks-control-plane-sg-"
  vpc_id      = aws_vpc.prima_vpc.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting this in a real-world scenario
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "prima-eks-control-plane-sg"
  }
}

# Security Group for EKS Worker Nodes
resource "aws_security_group" "prima_eks_nodes_sg" {
  name_prefix = "prima-eks-nodes-sg-"
  vpc_id      = aws_vpc.prima_vpc.id
  # Allow workers to connect to the control plane
  ingress {
    from_port   = 1025 - 65535 # Control plane ports
    to_port     = 65535
    protocol    = "tcp"
    security_groups = [aws_security_group.prima_eks_control_plane_sg.id]
  }
  # Allow workers to connect to the control plane (UDP)
  ingress {
    from_port   = 1025 - 65535 # Control plane ports
    to_port     = 65535
    protocol    = "udp"
    security_groups = [aws_security_group.prima_eks_control_plane_sg.id]
  }
  # Allow SSH access (for debugging - consider restricting in production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "prima-eks-nodes-sg"
  }
}

# IAM Role for the EKS Cluster
resource "aws_iam_role" "prima_eks_cluster_role" {
  name = "prima-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = { Service = "eks.amazonaws.com" }
      }
    ]
  })
}

# Attach AmazonEKSClusterPolicy to the EKS Cluster IAM Role
resource "aws_iam_role_policy_attachment" "prima_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.prima_eks_cluster_role.name
}

# IAM Role for the EKS Worker Nodes
resource "aws_iam_role" "prima_eks_node_role" {
  name = "prima-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })
}

# Attach necessary policies to the Worker Node IAM Role
resource "aws_iam_role_policy_attachment" "prima_eks_worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.prima_eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "prima_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.prima_eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "prima_ecr_readonly_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.prima_eks_node_role.name
}

# EKS Cluster
resource "aws_eks_cluster" "prima_eks_cluster" {
  name     = "prima-eks-cluster"
  role_arn = aws_iam_role.prima_eks_cluster_role.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids         = aws_subnet.prima_subnet[*].id
    security_group_ids = [aws_security_group.prima_eks_control_plane_sg.id]
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.prima_eks_cluster_policy,
    aws_security_group.prima_eks_control_plane_sg,
  ]

  tags = {
    Name = "prima-eks-cluster"
  }
}

# EKS Node Group
resource "aws_eks_node_group" "prima_nodes" {
  cluster_name    = aws_eks_cluster.prima_eks_cluster.name
  node_group_name = "prima-nodes"
  node_role_arn   = aws_iam_role.prima_eks_node_role.arn
  subnet_ids      = aws_subnet.prima_subnet[*].id

  scaling_config {
    desired_size = var.worker_desired_size
    max_size     = var.worker_max_size
    min_size     = var.worker_min_size
  }

  instance_types = [var.worker_instance_type]
  version        = var.eks_version

  opts {
    # Ensure nodes can join the cluster
    kubelet_args = ["--boto-kms-key-id", "alias/aws/eks"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.prima_eks_worker_policy,
    aws_iam_role_policy_attachment.prima_eks_cni_policy,
    aws_iam_role_policy_attachment.prima_ecr_readonly_policy,
    aws_security_group.prima_eks_nodes_sg,
  ]

  remote_access {
    ec2_ssh_key               = var.ec2_ssh_key_name
    source_security_group_ids = [aws_security_group.prima_eks_nodes_sg.id]
  }

  tags = {
    Name = "prima-worker-node"
  }
}