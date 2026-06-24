variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
}

variable "ami_id" {
  description = "Ubuntu AMI ID."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "key_name" {
  description = "Optional EC2 key pair name."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Public subnet ID."
  type        = string
}

variable "security_group_id" {
  description = "Application security group ID."
  type        = string
}

variable "docker_image" {
  description = "Frontend Docker image."
  type        = string
}

variable "backend_private_ip" {
  description = "Backend EC2 private IP."
  type        = string
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
