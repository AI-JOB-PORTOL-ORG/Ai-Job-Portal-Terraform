variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "az_count" {
  description = "Number of availability zones to use."
  type        = number
}

variable "public_subnet_cidrs" {
  description = "Optional explicit public subnet CIDR blocks."
  type        = list(string)
  default     = []
}

variable "private_app_subnet_cidrs" {
  description = "Optional explicit private application subnet CIDR blocks."
  type        = list(string)
  default     = []
}

variable "private_db_subnet_cidrs" {
  description = "Optional explicit private database subnet CIDR blocks."
  type        = list(string)
  default     = []
}

variable "single_nat_gateway" {
  description = "Whether to create one shared NAT Gateway instead of one per AZ."
  type        = bool
}

variable "eks_cluster_name" {
  description = "Optional future EKS cluster name for subnet discovery tags."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
