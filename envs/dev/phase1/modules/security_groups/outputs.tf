output "application_security_group_id" {
  description = "Application security group ID."
  value       = aws_security_group.application.id
}

output "database_security_group_id" {
  description = "Database security group ID."
  value       = aws_security_group.database.id
}
