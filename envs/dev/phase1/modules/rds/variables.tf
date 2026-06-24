variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
}

variable "subnet_ids" {
  description = "Private database subnet IDs."
  type        = list(string)
}

variable "database_security_group" {
  description = "Database security group ID."
  type        = string
}

variable "db_name" {
  description = "Initial database name."
  type        = string
}

variable "master_username" {
  description = "PostgreSQL master username."
  type        = string
}

variable "engine_version" {
  description = "Optional PostgreSQL engine version."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "allocated_storage" {
  description = "Initial allocated storage in GiB."
  type        = number
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage in GiB."
  type        = number
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment."
  type        = bool
}

variable "backup_retention_days" {
  description = "Automated backup retention period in days."
  type        = number
}

variable "deletion_protection" {
  description = "Enable deletion protection."
  type        = bool
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
