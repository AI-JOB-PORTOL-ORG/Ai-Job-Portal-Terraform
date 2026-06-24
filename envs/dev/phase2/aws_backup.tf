locals {
  backup_tags = merge(local.common_tags, {
    Name        = "hirevoice-rds-backup"
    Project     = "HireVoice"
    Environment = "Dev"
  })
}

data "aws_db_instance" "hirevoice_postgres" {
  db_instance_identifier = "hirevoice-dev-postgres"
}

data "aws_iam_policy_document" "aws_backup_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aws_backup_service_role" {
  name               = "${local.name_prefix}-aws-backup-service-role"
  assume_role_policy = data.aws_iam_policy_document.aws_backup_assume_role.json
  tags               = local.backup_tags
}

resource "aws_iam_role_policy_attachment" "aws_backup_service_role" {
  role       = aws_iam_role.aws_backup_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_backup_vault" "hirevoice" {
  name = "hirevoice-backup-vault"
  tags = merge(local.backup_tags, {
    Name = "hirevoice-backup-vault"
  })
}

resource "aws_backup_plan" "hirevoice_rds" {
  name = "hirevoice-rds-backup-plan"

  rule {
    rule_name         = "daily-rds-backup-30-day-retention"
    target_vault_name = aws_backup_vault.hirevoice.name
    schedule          = "cron(0 5 * * ? *)"

    lifecycle {
      delete_after = 30
    }
  }

  tags = merge(local.backup_tags, {
    Name = "hirevoice-rds-backup-plan"
  })
}

resource "aws_backup_selection" "hirevoice_rds" {
  iam_role_arn = aws_iam_role.aws_backup_service_role.arn
  name         = "hirevoice-rds-backup-selection"
  plan_id      = aws_backup_plan.hirevoice_rds.id
  resources    = [data.aws_db_instance.hirevoice_postgres.db_instance_arn]

  depends_on = [
    aws_iam_role_policy_attachment.aws_backup_service_role
  ]
}
