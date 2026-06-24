variable "name_prefix" {
  description = "Name prefix for AWS Load Balancer Controller IAM resources."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID used by the EKS cluster."
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
  description = "Kubernetes namespace for the AWS Load Balancer Controller."
  type        = string
  default     = "kube-system"
}

variable "service_account_name" {
  description = "Kubernetes service account name for the AWS Load Balancer Controller."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "chart_version" {
  description = "Optional aws-load-balancer-controller Helm chart version. Null lets Helm install the latest chart from the repository."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to IAM resources."
  type        = map(string)
  default     = {}
}
