variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Optional Kubernetes version for the EKS cluster."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "Existing VPC ID."
  type        = string
}

variable "public_subnet_ids" {
  description = "Existing public subnet IDs for future ALB placement and EKS control plane subnet awareness."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Existing private application subnet IDs for EKS worker nodes."
  type        = list(string)
}

variable "node_instance_types" {
  description = "Instance types for the managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_min_size" {
  description = "Minimum managed node group size."
  type        = number
  default     = 2
}

variable "node_desired_size" {
  description = "Desired managed node group size."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum managed node group size."
  type        = number
  default     = 4
}

variable "tags" {
  description = "Tags applied to EKS resources."
  type        = map(string)
  default     = {}
}
