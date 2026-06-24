locals {
  aws_region        = "us-east-1"
  cluster_name      = "hirevoice-dev-eks"
  account_id        = "334401495505"
  name_prefix       = "hirevoice-dev"
  oidc_provider_arn = "arn:aws:iam::334401495505:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/117E18B51548CBB28BC7A5D28527DBE3"
  oidc_provider_url = "oidc.eks.us-east-1.amazonaws.com/id/117E18B51548CBB28BC7A5D28527DBE3"
  cluster_vpc_id    = data.aws_eks_cluster.hirevoice.vpc_config[0].vpc_id

  alb_namespace            = "kube-system"
  alb_service_account_name = "aws-load-balancer-controller"
  eso_namespace            = "external-secrets"
  eso_service_account_name = "external-secrets"

  common_tags = {
    Project     = "hirevoice"
    Environment = "dev"
    ManagedBy   = "terraform"
    Phase       = "phase2-cluster-addons"
  }
}

data "aws_iam_policy_document" "alb_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:${local.alb_namespace}:${local.alb_service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eso_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:${local.eso_namespace}:${local.eso_service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eso_secrets_read" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "arn:aws:secretsmanager:${local.aws_region}:${local.account_id}:secret:hirevoice-dev/*",
      "arn:aws:secretsmanager:${local.aws_region}:${local.account_id}:secret:rds!*"
    ]
  }
}

resource "aws_iam_role" "aws_load_balancer_controller_irsa" {
  name               = "${local.name_prefix}-aws-load-balancer-controller-irsa"
  assume_role_policy = data.aws_iam_policy_document.alb_assume_role.json
  tags               = local.common_tags
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "${local.name_prefix}-aws-load-balancer-controller"
  description = "IAM permissions for AWS Load Balancer Controller in the HireVoice personal account"
  policy      = file("${path.module}/policies/aws-load-balancer-controller-iam-policy.json")
  tags        = local.common_tags
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = aws_iam_role.aws_load_balancer_controller_irsa.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

resource "aws_iam_role" "external_secrets_irsa" {
  name               = "${local.name_prefix}-external-secrets-irsa"
  assume_role_policy = data.aws_iam_policy_document.eso_assume_role.json
  tags               = local.common_tags
}

resource "aws_iam_policy" "external_secrets_read" {
  name        = "${local.name_prefix}-external-secrets-read"
  description = "Allow External Secrets Operator to read HireVoice secrets"
  policy      = data.aws_iam_policy_document.eso_secrets_read.json
  tags        = local.common_tags
}

resource "aws_iam_role_policy_attachment" "external_secrets_read" {
  role       = aws_iam_role.external_secrets_irsa.name
  policy_arn = aws_iam_policy.external_secrets_read.arn
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = local.alb_namespace
  wait       = true
  timeout    = 600

  set {
    name  = "clusterName"
    value = local.cluster_name
  }

  set {
    name  = "region"
    value = local.aws_region
  }

  set {
    name  = "vpcId"
    value = local.cluster_vpc_id
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = local.alb_service_account_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller_irsa.arn
  }

  depends_on = [
    aws_iam_role_policy_attachment.aws_load_balancer_controller
  ]
}

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = local.eso_namespace
  create_namespace = true
  wait             = true
  timeout          = 600

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = local.eso_service_account_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_secrets_irsa.arn
  }

  depends_on = [
    aws_iam_role_policy_attachment.external_secrets_read
  ]
}

output "alb_controller_release" {
  value = helm_release.aws_load_balancer_controller.name
}

output "external_secrets_release" {
  value = helm_release.external_secrets.name
}

output "cluster_vpc_id" {
  value = local.cluster_vpc_id
}

output "aws_load_balancer_controller_irsa_role_arn" {
  value = aws_iam_role.aws_load_balancer_controller_irsa.arn
}

output "external_secrets_irsa_role_arn" {
  value = aws_iam_role.external_secrets_irsa.arn
}
