# external_secrets.tf manages the in-cluster components of our secrets provider.
#
# The AWS IAM resources for this are in
# ../cluster-infrastructure/external_secrets_iam.tf.

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "0.7.2" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = local.services_ns
  create_namespace = true
  values = [yamlencode({
    replicaCount = var.desired_ha_replicas
    serviceAccount = {
      name = data.terraform_remote_state.cluster_infrastructure.outputs.external_secrets_service_account_name
      annotations = {
        "eks.amazonaws.com/role-arn" = data.terraform_remote_state.cluster_infrastructure.outputs.external_secrets_role_arn
      }
    }
    certController = {
      replicaCount = var.desired_ha_replicas
    }
    webhook = {
      replicaCount = var.desired_ha_replicas
    }
  })]
}

resource "helm_release" "cluster_secret_store" {
  # We require the CRD for ClusterSecretStore from helm_release.external_secrets
  # before this resource can be created.
  depends_on = [helm_release.external_secrets]

  name       = "cluster-secret-store"
  repository = "https://alphagov.github.io/govuk-helm-charts/"
  chart      = "cluster-secret-store"
  version    = "0.1.1" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace  = local.services_ns
  values = [yamlencode({
    awsRegion          = data.aws_region.current.name
    serviceAccountName = data.terraform_remote_state.cluster_infrastructure.outputs.external_secrets_service_account_name
  })]
}

# Required by cluster-secrets chart, but it won't create it itself
# (even if create_namespace = true is set)
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "cluster_secrets" {
  depends_on = [helm_release.cluster_secret_store, kubernetes_namespace.monitoring]

  chart      = "cluster-secrets"
  name       = "cluster-secrets"
  namespace  = local.services_ns
  repository = "https://alphagov.github.io/govuk-helm-charts/"
  version    = "0.9.5" # TODO: Dependabot or equivalent so this doesn't get neglected.
}
