resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = var.external_secrets_namespace
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
    value = "external-secrets"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.external_secrets_role_arn
  }
}

resource "time_sleep" "external_secrets_crds" {
  create_duration = "60s"

  depends_on = [
    helm_release.external_secrets
  ]
}

resource "kubernetes_namespace" "hirevoice" {
  metadata {
    name = var.hirevoice_namespace
  }
}

resource "kubernetes_manifest" "secret_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ClusterSecretStore"

    metadata = {
      name = "aws-secrets-manager"
    }

    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.aws_region

          auth = {
            jwt = {
              serviceAccountRef = {
                name      = "external-secrets"
                namespace = var.external_secrets_namespace
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    time_sleep.external_secrets_crds,
    kubernetes_namespace.hirevoice
  ]
}

resource "kubernetes_manifest" "jwt_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"

    metadata = {
      name      = "jwt-secret"
      namespace = var.hirevoice_namespace
    }

    spec = {
      refreshInterval = "1h"

      secretStoreRef = {
        name = kubernetes_manifest.secret_store.manifest.metadata.name
        kind = "ClusterSecretStore"
      }

      target = {
        name           = "jwt-secret"
        creationPolicy = "Owner"
      }

      data = [
        {
          secretKey = "JWT_SECRET"
          remoteRef = {
            key = var.jwt_secret_name
          }
        }
      ]
    }
  }

  depends_on = [
    kubernetes_manifest.secret_store
  ]
}

resource "kubernetes_manifest" "groq_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"

    metadata = {
      name      = "groq-api-key"
      namespace = var.hirevoice_namespace
    }

    spec = {
      refreshInterval = "1h"

      secretStoreRef = {
        name = kubernetes_manifest.secret_store.manifest.metadata.name
        kind = "ClusterSecretStore"
      }

      target = {
        name           = "groq-api-key"
        creationPolicy = "Owner"
      }

      data = [
        {
          secretKey = "GROQ_API_KEY"
          remoteRef = {
            key = var.groq_secret_name
          }
        }
      ]
    }
  }

  depends_on = [
    kubernetes_manifest.secret_store
  ]
}

resource "kubernetes_manifest" "rds_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"

    metadata = {
      name      = "rds-credentials"
      namespace = var.hirevoice_namespace
    }

    spec = {
      refreshInterval = "1h"

      secretStoreRef = {
        name = kubernetes_manifest.secret_store.manifest.metadata.name
        kind = "ClusterSecretStore"
      }

      target = {
        name           = "rds-credentials"
        creationPolicy = "Owner"
      }

      data = [
        {
          secretKey = "DB_USER"
          remoteRef = {
            key      = var.rds_secret_name
            property = "username"
          }
        },
        {
          secretKey = "DB_PASSWORD"
          remoteRef = {
            key      = var.rds_secret_name
            property = "password"
          }
        }
      ]
    }
  }

  depends_on = [
    kubernetes_manifest.secret_store
  ]
}
