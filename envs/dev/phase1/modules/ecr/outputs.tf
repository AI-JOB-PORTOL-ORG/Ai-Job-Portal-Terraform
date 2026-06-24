output "frontend_repository_url" {
  description = "ECR repository URL for the HireVoice frontend image."
  value       = aws_ecr_repository.this["frontend"].repository_url
}

output "backend_repository_url" {
  description = "ECR repository URL for the HireVoice backend image."
  value       = aws_ecr_repository.this["backend"].repository_url
}

output "repository_arns" {
  description = "ECR repository ARNs keyed by logical repository name."
  value       = { for name, repository in aws_ecr_repository.this : name => repository.arn }
}

output "repository_urls" {
  description = "ECR repository URLs keyed by logical repository name."
  value       = { for name, repository in aws_ecr_repository.this : name => repository.repository_url }
}
