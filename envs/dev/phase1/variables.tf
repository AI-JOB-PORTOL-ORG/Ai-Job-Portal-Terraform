variable "aws_region" {
  description = "AWS region for the HireVoice Phase 1 infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource names and tags."
  type        = string
  default     = "hirevoice"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.project_name))
    error_message = "project_name must be a lowercase slug using letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.environment))
    error_message = "environment must be a lowercase slug using letters, numbers, and hyphens."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to use. Phase 1 requires two."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count == 2
    error_message = "Phase 1 is designed for exactly two availability zones."
  }
}

variable "public_subnet_cidrs" {
  description = "Optional explicit CIDR blocks for public subnets. Leave empty to derive from vpc_cidr."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.public_subnet_cidrs) == 0 || length(var.public_subnet_cidrs) == 2
    error_message = "public_subnet_cidrs must be empty or contain exactly two CIDR blocks."
  }
}

variable "private_app_subnet_cidrs" {
  description = "Optional explicit CIDR blocks for private application subnets. Leave empty to derive from vpc_cidr."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.private_app_subnet_cidrs) == 0 || length(var.private_app_subnet_cidrs) == 2
    error_message = "private_app_subnet_cidrs must be empty or contain exactly two CIDR blocks."
  }
}

variable "private_db_subnet_cidrs" {
  description = "Optional explicit CIDR blocks for private database subnets. Leave empty to derive from vpc_cidr."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.private_db_subnet_cidrs) == 0 || length(var.private_db_subnet_cidrs) == 2
    error_message = "private_db_subnet_cidrs must be empty or contain exactly two CIDR blocks."
  }
}

variable "single_nat_gateway" {
  description = "Use one NAT Gateway to reduce Phase 1 cost. Set false for one NAT Gateway per AZ."
  type        = bool
  default     = true
}

variable "allowed_web_cidrs" {
  description = "IPv4 CIDR blocks allowed to reach the application security group on HTTP and HTTPS."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "postgres_engine_version" {
  description = "Optional PostgreSQL engine version. Null lets AWS select the current default supported by the provider/API."
  type        = string
  default     = null
}

variable "postgres_instance_class" {
  description = "RDS PostgreSQL instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "postgres_db_name" {
  description = "Initial PostgreSQL database name."
  type        = string
  default     = "hirevoice"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]*$", var.postgres_db_name))
    error_message = "postgres_db_name must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "postgres_master_username" {
  description = "RDS PostgreSQL master username."
  type        = string
  default     = "hirevoice_admin"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]*$", var.postgres_master_username))
    error_message = "postgres_master_username must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "postgres_allocated_storage" {
  description = "Initial PostgreSQL allocated storage in GiB."
  type        = number
  default     = 20
}

variable "postgres_max_allocated_storage" {
  description = "Maximum PostgreSQL storage for autoscaling in GiB."
  type        = number
  default     = 100
}

variable "postgres_multi_az" {
  description = "Enable RDS Multi-AZ deployment."
  type        = bool
  default     = false
}

variable "postgres_backup_retention_days" {
  description = "Automated backup retention period in days."
  type        = number
  default     = 7

  validation {
    condition     = var.postgres_backup_retention_days >= 1 && var.postgres_backup_retention_days <= 35
    error_message = "postgres_backup_retention_days must be between 1 and 35."
  }
}

variable "postgres_deletion_protection" {
  description = "Enable deletion protection for the RDS instance."
  type        = bool
  default     = true
}

variable "screen_pass_threshold" {
  description = "Application screening score threshold stored in SSM Parameter Store."
  type        = number
  default     = 60
}

variable "groq_api_key" {
  description = "Groq API key stored in Secrets Manager for the backend EC2 runtime."
  type        = string
  sensitive   = true
}

variable "ubuntu_ami_id" {
  description = "Ubuntu Server 26.04 LTS AMI ID for Phase 2 EC2 instances in us-east-1."
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}

variable "frontend_instance_type" {
  description = "EC2 instance type for the frontend host."
  type        = string
  default     = "t3.micro"
}

variable "backend_instance_type" {
  description = "EC2 instance type for the backend host."
  type        = string
  default     = "t3.small"
}

variable "ec2_key_name" {
  description = "Optional EC2 key pair name for SSH access. Null disables SSH key injection."
  type        = string
  default     = null
}

variable "frontend_docker_image" {
  description = "Frontend Docker image to deploy on EC2."
  type        = string
  default     = "kajapathy/ai-job-portal-frontend:v2"
}

variable "backend_docker_image" {
  description = "Backend Docker image to deploy on EC2."
  type        = string
  default     = "kajapathy/ai-job-portal-backend:v2"
}

variable "run_seed_data" {
  description = "Run python seed.py during backend EC2 user-data after database bootstrap."
  type        = bool
  default     = false
}

variable "eks_cluster_version" {
  description = "Optional Kubernetes version for the EKS cluster. Null lets AWS use its default supported version."
  type        = string
  default     = null
}

variable "eks_node_instance_types" {
  description = "EC2 instance types for the EKS managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_min_size" {
  description = "Minimum number of EKS managed nodes."
  type        = number
  default     = 2
}

variable "eks_node_desired_size" {
  description = "Desired number of EKS managed nodes."
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Maximum number of EKS managed nodes."
  type        = number
  default     = 4
}

variable "eks_cluster_name" {
  description = "Optional future EKS cluster name used only for subnet discovery tags. Does not create EKS."
  type        = string
  default     = null
}

variable "domain_name" {
  description = "Root domain name delegated to Route53 for HireVoice."
  type        = string
  default     = "in-sur.site"
}

variable "hirevoice_subdomain" {
  description = "Subdomain used for the HireVoice application."
  type        = string
  default     = "hirevoice"
}

variable "hirevoice_alb_name" {
  description = "Existing AWS Load Balancer Controller ALB name for the HireVoice Ingress."
  type        = string
  default     = "k8s-hirevoic-hirevoic-36e944838f"
}

variable "tags" {
  description = "Additional tags applied to all supported resources."
  type        = map(string)
  default     = {}
}
