output "iam_role_name" {
  description = "AWS Load Balancer Controller IRSA role name."
  value       = aws_iam_role.this.name
}

output "iam_role_arn" {
  description = "AWS Load Balancer Controller IRSA role ARN."
  value       = aws_iam_role.this.arn
}

output "iam_policy_arn" {
  description = "AWS Load Balancer Controller IAM policy ARN."
  value       = aws_iam_policy.this.arn
}

output "helm_release_name" {
  description = "AWS Load Balancer Controller Helm release name."
  value       = helm_release.this.name
}

output "service_account_name" {
  description = "AWS Load Balancer Controller Kubernetes service account name."
  value       = var.service_account_name
}
