# external_secrets.tf manages the in-cluster components of our secrets provider.
#
# The AWS IAM resources for this are in
# ../cluster-infrastructure/external_secrets_iam.tf.

# Required by cluster-secrets chart, but it won't create it itself
# (even if create_namespace = true is set)
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "external_secrets" {
  depends_on = [helm_release.aws_lb_controller]

  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "0.15.1"
  namespace        = local.services_ns
  create_namespace = true
  values = [yamlencode({
    replicaCount = var.desired_ha_replicas
    serviceAccount = {
      name = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.external_secrets_service_account_name
      annotations = {
        "eks.amazonaws.com/role-arn" = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.external_secrets_role_arn
      }
    }
    certController = {
      replicaCount = var.desired_ha_replicas
    }
    webhook = {
      replicaCount = var.desired_ha_replicas
    }
  })]

  lifecycle {
    create_before_destroy = true
  }
}

resource "helm_release" "cluster_secret_store" {
  # We require the CRD for ClusterSecretStore from helm_release.external_secrets
  # before this resource can be created.

  name       = "cluster-secret-store"
  repository = "https://alphagov.github.io/govuk-helm-charts/"
  chart      = "cluster-secret-store"
  version    = "0.2.0" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace  = local.services_ns
  timeout    = var.helm_timeout_seconds
  values = [yamlencode({
    awsRegion          = data.aws_region.current.name
    serviceAccountName = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.external_secrets_service_account_name
  })]

  depends_on = [helm_release.external_secrets]
}

resource "helm_release" "cluster_secrets" {
  depends_on = [helm_release.cluster_secret_store, kubernetes_namespace.monitoring]

  chart      = "cluster-secrets"
  name       = "cluster-secrets"
  namespace  = local.services_ns
  repository = "https://alphagov.github.io/govuk-helm-charts/"
  version    = "0.9.5" # TODO: Dependabot or equivalent so this doesn't get neglected.
  timeout    = var.helm_timeout_seconds
}
