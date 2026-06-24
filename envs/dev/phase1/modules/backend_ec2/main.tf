locals {
  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    aws_region            = var.aws_region
    docker_image          = var.docker_image
    db_host               = var.db_host
    db_port               = var.db_port
    rds_secret_arn        = var.rds_secret_arn
    jwt_secret_arn        = var.jwt_secret_arn
    groq_secret_arn       = var.groq_secret_arn
    auth_db_name          = var.auth_db_name
    jobs_db_name          = var.jobs_db_name
    screen_pass_threshold = var.screen_pass_threshold
    run_seed_data         = var.run_seed_data ? "true" : "false"
  })
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = false
  iam_instance_profile        = var.instance_profile_name
  key_name                    = var.key_name
  user_data                   = local.user_data
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_size = 20
    volume_type = "gp3"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-backend"
    Role = "backend"
  })
}
