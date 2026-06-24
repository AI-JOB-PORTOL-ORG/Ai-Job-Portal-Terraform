output "instance_id" {
  description = "Backend EC2 instance ID."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Backend EC2 private IP."
  value       = aws_instance.this.private_ip
}
