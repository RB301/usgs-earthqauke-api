variable "aws_region" {
  type        = string
  description = "The AWS region to deploy to"
  default     = "us-west-2"
}

variable "eks_version" {
  type        = string
  description = "The Kubernetes version for the EKS cluster and nodes"
  default     = "1.21"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_mask" {
  type        = number
  description = "The number of additional bits to allocate for subnets"
  default     = 8
}

variable "worker_desired_size" {
  type        = number
  description = "The desired number of worker nodes"
  default     = 2
}

variable "worker_max_size" {
  type        = number
  description = "The maximum number of worker nodes"
  default     = 3
}

variable "worker_min_size" {
  type        = number
  description = "The minimum number of worker nodes"
  default     = 1
}

variable "worker_instance_type" {
  type        = string
  description = "The EC2 instance type for the worker nodes"
  default     = "t2.micro"
}

variable "ec2_ssh_key_name" {
  type        = string
  description = "The name of the EC2 SSH key pair to allow SSH access to worker nodes (leave empty if not needed)"
  default     = ""
}