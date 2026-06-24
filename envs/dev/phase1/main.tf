module "networking" {
  source = "./modules/networking"

  name_prefix              = local.name_prefix
  vpc_cidr                 = var.vpc_cidr
  az_count                 = var.az_count
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  single_nat_gateway       = var.single_nat_gateway
  eks_cluster_name         = var.eks_cluster_name
  tags                     = local.common_tags
}

module "security_groups" {
  source = "./modules/security_groups"

  name_prefix       = local.name_prefix
  vpc_id            = module.networking.vpc_id
  allowed_web_cidrs = var.allowed_web_cidrs
  tags              = local.common_tags
}

module "rds" {
  source = "./modules/rds"

  name_prefix             = local.name_prefix
  subnet_ids              = module.networking.private_db_subnet_ids
  database_security_group = module.security_groups.database_security_group_id
  db_name                 = var.postgres_db_name
  master_username         = var.postgres_master_username
  engine_version          = var.postgres_engine_version
  instance_class          = var.postgres_instance_class
  allocated_storage       = var.postgres_allocated_storage
  max_allocated_storage   = var.postgres_max_allocated_storage
  multi_az                = var.postgres_multi_az
  backup_retention_days   = var.postgres_backup_retention_days
  deletion_protection     = var.postgres_deletion_protection
  tags                    = local.common_tags
}

module "configuration" {
  source = "./modules/configuration"

  name_prefix = local.name_prefix
  environment = var.environment

  parameters = {
    ENVIRONMENT           = var.environment
    AWS_REGION            = var.aws_region
    DB_HOST               = module.rds.rds_address
    DB_PORT               = tostring(module.rds.rds_port)
    DB_NAME               = var.postgres_db_name
    AUTH_DB_NAME          = "hirevoice_auth"
    JOBS_DB_NAME          = "hirevoice_jobs"
    SCREENING_DB_NAME     = "hirevoice_screening"
    INTERVIEW_DB_NAME     = "hirevoice_interview"
    SCREEN_PASS_THRESHOLD = tostring(var.screen_pass_threshold)
    RDS_MASTER_SECRET_ARN = module.rds.master_user_secret_arn
  }

  additional_secrets = {
    groq-api-key = var.groq_api_key
  }

  tags = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name        = coalesce(var.eks_cluster_name, "${local.name_prefix}-eks")
  cluster_version     = var.eks_cluster_version
  vpc_id              = module.networking.vpc_id
  public_subnet_ids   = module.networking.public_subnet_ids
  private_subnet_ids  = module.networking.private_app_subnet_ids
  node_instance_types = var.eks_node_instance_types
  node_min_size       = var.eks_node_min_size
  node_desired_size   = var.eks_node_desired_size
  node_max_size       = var.eks_node_max_size
  tags                = local.common_tags
}
