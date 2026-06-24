variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "parameters" {
  description = "Non-sensitive application configuration values."
  type        = map(string)
  default     = {}
}

variable "additional_secrets" {
  description = "Optional additional Secrets Manager secret values."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
