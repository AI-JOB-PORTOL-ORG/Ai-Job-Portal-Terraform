resource "random_password" "jwt_secret" {
  length  = 48
  special = true
}

locals {
  parameter_path = "/hirevoice/${var.environment}"
}

resource "aws_ssm_parameter" "app" {
  for_each = var.parameters

  name        = "${local.parameter_path}/${each.key}"
  description = "HireVoice ${var.environment} ${each.key}"
  type        = "String"
  value       = each.value

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${lower(each.key)}"
  })
}

resource "aws_secretsmanager_secret" "jwt" {
  name                    = "${var.name_prefix}/jwt-secret"
  description             = "JWT signing secret for HireVoice ${var.environment}"
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-jwt-secret"
  })
}

resource "aws_secretsmanager_secret_version" "jwt" {
  secret_id     = aws_secretsmanager_secret.jwt.id
  secret_string = random_password.jwt_secret.result
}

resource "aws_secretsmanager_secret" "additional" {
  for_each = nonsensitive(toset(keys(var.additional_secrets)))

  name                    = "${var.name_prefix}/${each.value}"
  description             = "HireVoice ${var.environment} ${each.key}"
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.value}"
  })
}

resource "aws_secretsmanager_secret_version" "additional" {
  for_each = nonsensitive(toset(keys(var.additional_secrets)))

  secret_id     = aws_secretsmanager_secret.additional[each.value].id
  secret_string = var.additional_secrets[each.value]
}
