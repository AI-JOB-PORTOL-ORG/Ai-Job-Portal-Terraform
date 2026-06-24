variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "allowed_web_cidrs" {
  description = "IPv4 CIDR blocks allowed to reach the application security group."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
