output "role_name" {
  description = "IRSA IAM role name."
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "IRSA IAM role ARN."
  value       = aws_iam_role.this.arn
}

output "policy_arn" {
  description = "Secrets read policy ARN."
  value       = aws_iam_policy.secrets_read.arn
}
