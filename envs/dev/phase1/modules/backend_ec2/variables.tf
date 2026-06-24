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
  description = "Private application subnet ID."
  type        = string
}

variable "security_group_id" {
  description = "Application security group ID."
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name."
  type        = string
}

variable "docker_image" {
  description = "Backend Docker image."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "db_host" {
  description = "RDS PostgreSQL hostname."
  type        = string
}

variable "db_port" {
  description = "RDS PostgreSQL port."
  type        = number
}

variable "rds_secret_arn" {
  description = "RDS managed master user secret ARN."
  type        = string
}

variable "jwt_secret_arn" {
  description = "JWT secret ARN."
  type        = string
}

variable "groq_secret_arn" {
  description = "Groq API key secret ARN."
  type        = string
}

variable "auth_db_name" {
  description = "Auth service database name."
  type        = string
}

variable "jobs_db_name" {
  description = "Jobs service database name."
  type        = string
}

variable "screen_pass_threshold" {
  description = "Resume screening pass threshold."
  type        = number
}

variable "run_seed_data" {
  description = "Run python seed.py after database bootstrap."
  type        = bool
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
