output "instance_id" {
  description = "Frontend EC2 instance ID."
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Frontend EC2 public IP."
  value       = aws_instance.this.public_ip
}

output "public_url" {
  description = "Frontend public URL."
  value       = "http://${aws_instance.this.public_ip}"
}
