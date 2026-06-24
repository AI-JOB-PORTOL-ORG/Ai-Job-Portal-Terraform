variable "frontend_repository_name" {
  description = "ECR repository name for the HireVoice frontend image."
  type        = string
  default     = "hirevoice-frontend"
}

variable "backend_repository_name" {
  description = "ECR repository name for the HireVoice backend image."
  type        = string
  default     = "hirevoice-backend"
}

variable "tags" {
  description = "Tags applied to ECR resources."
  type        = map(string)
  default     = {}
}
