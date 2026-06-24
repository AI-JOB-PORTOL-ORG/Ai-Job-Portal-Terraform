output "parameter_path" {
  description = "SSM Parameter Store path for application configuration."
  value       = local.parameter_path
}

output "parameter_arns" {
  description = "SSM parameter ARNs."
  value       = [for parameter in aws_ssm_parameter.app : parameter.arn]
}

output "jwt_secret_arn" {
  description = "JWT secret ARN."
  value       = aws_secretsmanager_secret.jwt.arn
}

output "additional_secret_arns" {
  description = "Additional application secret ARNs."
  value       = [for secret in aws_secretsmanager_secret.additional : secret.arn]
}

output "additional_secret_arn_by_name" {
  description = "Additional application secret ARNs keyed by secret short name."
  value       = { for name, secret in aws_secretsmanager_secret.additional : name => secret.arn }
}
