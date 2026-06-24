output "external_secrets_release_name" {
  description = "External Secrets Operator Helm release name."
  value       = helm_release.external_secrets.name
}

output "hirevoice_namespace" {
  description = "Namespace containing HireVoice ExternalSecret outputs."
  value       = kubernetes_namespace.hirevoice.metadata[0].name
}

output "secret_store_name" {
  description = "External Secrets ClusterSecretStore name."
  value       = kubernetes_manifest.secret_store.manifest.metadata.name
}

output "external_secret_names" {
  description = "ExternalSecret resource names managed by Terraform."
  value = [
    kubernetes_manifest.jwt_external_secret.manifest.metadata.name,
    kubernetes_manifest.groq_external_secret.manifest.metadata.name,
    kubernetes_manifest.rds_external_secret.manifest.metadata.name
  ]
}
