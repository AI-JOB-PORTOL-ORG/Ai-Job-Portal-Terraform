data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "app_configuration_read" {
  statement {
    sid     = "ReadConfigurationParameters"
    effect  = "Allow"
    actions = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]

    resources = var.configuration_parameter_arns
  }

  statement {
    sid     = "ReadApplicationSecrets"
    effect  = "Allow"
    actions = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]

    resources = var.secret_arns
  }
}

resource "aws_iam_role" "ec2_workload" {
  name               = "${var.name_prefix}-ec2-workload-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ec2-workload-role"
  })
}

resource "aws_iam_policy" "app_configuration_read" {
  name        = "${var.name_prefix}-app-config-read"
  description = "Allow HireVoice application hosts to read configuration and secrets"
  policy      = data.aws_iam_policy_document.app_configuration_read.json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-config-read"
  })
}

resource "aws_iam_role_policy_attachment" "app_configuration_read" {
  role       = aws_iam_role.ec2_workload.name
  policy_arn = aws_iam_policy.app_configuration_read.arn
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance" {
  role       = aws_iam_role.ec2_workload.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_workload.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_workload" {
  name = "${var.name_prefix}-ec2-workload-profile"
  role = aws_iam_role.ec2_workload.name

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ec2-workload-profile"
  })
}
