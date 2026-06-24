output "vpc_id" {
  description = "VPC ID."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs across two AZs."
  value       = module.networking.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Private application subnet IDs across two AZs."
  value       = module.networking.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "Private database subnet IDs across two AZs."
  value       = module.networking.private_db_subnet_ids
}

output "application_security_group_id" {
  description = "Application security group ID."
  value       = module.security_groups.application_security_group_id
}

output "database_security_group_id" {
  description = "Database security group ID."
  value       = module.security_groups.database_security_group_id
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint."
  value       = module.rds.rds_endpoint
}

output "rds_port" {
  description = "RDS PostgreSQL port."
  value       = module.rds.rds_port
}

output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN."
  value       = module.eks.cluster_arn
}

output "eks_oidc_provider_arn" {
  description = "EKS OIDC provider ARN for future IRSA integration."
  value       = module.eks.oidc_provider_arn
}

output "eks_node_group_name" {
  description = "EKS managed node group name."
  value       = module.eks.node_group_name
}

output "eks_node_security_group_id" {
  description = "Dedicated EKS node security group ID."
  value       = module.eks.node_security_group_id
}

output "configuration_parameter_path" {
  description = "SSM parameter path containing non-sensitive application configuration."
  value       = module.configuration.parameter_path
}
