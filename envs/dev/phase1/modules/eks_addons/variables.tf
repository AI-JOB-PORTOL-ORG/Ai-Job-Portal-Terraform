variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "external_secrets_role_arn" {
  description = "IRSA role ARN for the External Secrets Operator service account."
  type        = string
}

variable "external_secrets_namespace" {
  description = "Namespace for External Secrets Operator."
  type        = string
  default     = "external-secrets"
}

variable "hirevoice_namespace" {
  description = "Namespace for HireVoice application secrets."
  type        = string
  default     = "hirevoice"
}

variable "jwt_secret_name" {
  description = "AWS Secrets Manager secret name for the JWT secret."
  type        = string
}

variable "groq_secret_name" {
  description = "AWS Secrets Manager secret name for the Groq API key."
  type        = string
}

variable "rds_secret_name" {
  description = "AWS Secrets Manager secret name or ARN for the RDS master user secret."
  type        = string
}
