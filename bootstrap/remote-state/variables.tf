variable "aws_region" {
  description = "AWS region for the Terraform remote state backend resources."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state storage."
  type        = string
  default     = "hirevoice-terraform-state-334401495505"
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking."
  type        = string
  default     = "hirevoice-terraform-locks"
}

variable "tags" {
  description = "Tags applied to Terraform backend resources."
  type        = map(string)
  default = {
    Project     = "hirevoice"
    Environment = "dev"
    ManagedBy   = "terraform"
    Purpose     = "terraform-remote-state"
  }
}
