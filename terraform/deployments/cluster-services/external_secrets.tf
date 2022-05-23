# external_secrets.tf manages the in-cluster components of our secrets provider.
#
# The AWS IAM resources for this are in
# ../cluster-infrastructure/external_secrets_iam.tf.

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "0.5.3" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = local.services_ns
  create_namespace = true
  values = [yamlencode({
    serviceAccount = {
      name = data.terraform_remote_state.cluster_infrastructure.outputs.external_secrets_service_account_name
      annotations = {
        "eks.amazonaws.com/role-arn" = data.terraform_remote_state.cluster_infrastructure.outputs.external_secrets_role_arn
      }
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

resource "helm_release" "cluster_secrets" {
  depends_on = [helm_release.cluster_secret_store]

  chart      = "cluster-secrets"
  name       = "cluster-secrets"
  namespace  = local.services_ns
  repository = "https://alphagov.github.io/govuk-helm-charts/"
  version    = "0.9.3" # TODO: Dependabot or equivalent so this doesn't get neglected.
}
