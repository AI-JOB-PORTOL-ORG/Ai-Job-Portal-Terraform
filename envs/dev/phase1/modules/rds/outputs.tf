output "rds_endpoint" {
  description = "RDS endpoint with port."
  value       = aws_db_instance.this.endpoint
}

output "rds_address" {
  description = "RDS hostname."
  value       = aws_db_instance.this.address
}

output "rds_port" {
  description = "RDS port."
  value       = aws_db_instance.this.port
}

output "db_subnet_group_name" {
  description = "DB subnet group name."
  value       = aws_db_subnet_group.this.name
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN for the RDS managed master user password."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
