variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
}

variable "role_name" {
  description = "IAM role name."
  type        = string
}

variable "oidc_provider_arn" {
  description = "EKS OIDC provider ARN."
  type        = string
}

variable "oidc_provider_url" {
  description = "EKS OIDC provider URL without the https:// prefix."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the service account."
  type        = string
}

variable "service_account_name" {
  description = "Kubernetes service account name."
  type        = string
}

variable "secret_arns" {
  description = "Secrets Manager ARNs readable by this IRSA role."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to IAM resources."
  type        = map(string)
  default     = {}
}
