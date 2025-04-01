output "eks_cluster_name" {
  value       = aws_eks_cluster.prima_eks_cluster.name
  description = "The name of the EKS cluster"
}

output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.prima_eks_cluster.endpoint
  description = "The endpoint for the EKS cluster"
}

output "worker_node_security_group_id" {
  value       = aws_security_group.prima_eks_nodes_sg.id
  description = "The ID of the security group for the EKS worker nodes"
}

output "vpc_id" {
  value       = aws_vpc.prima_vpc.id
  description = "The ID of the VPC"
}

output "subnet_ids" {
  value       = aws_subnet.prima_subnet[*].id
  description = "A list of subnet IDs"
}