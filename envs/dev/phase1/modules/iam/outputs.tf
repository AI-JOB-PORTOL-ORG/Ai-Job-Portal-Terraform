output "ec2_workload_role_name" {
  description = "EC2 workload IAM role name."
  value       = aws_iam_role.ec2_workload.name
}

output "ec2_workload_role_arn" {
  description = "EC2 workload IAM role ARN."
  value       = aws_iam_role.ec2_workload.arn
}

output "ec2_instance_profile_name" {
  description = "EC2 instance profile name."
  value       = aws_iam_instance_profile.ec2_workload.name
}

output "ec2_instance_profile_arn" {
  description = "EC2 instance profile ARN."
  value       = aws_iam_instance_profile.ec2_workload.arn
}
