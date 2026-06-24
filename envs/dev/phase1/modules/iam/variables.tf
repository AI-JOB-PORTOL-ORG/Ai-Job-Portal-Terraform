variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
}

variable "configuration_parameter_arns" {
  description = "SSM parameter ARNs application workloads can read."
  type        = list(string)
  default     = []
}

variable "secret_arns" {
  description = "Secrets Manager secret ARNs application workloads can read."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
