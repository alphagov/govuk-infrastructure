data "aws_secretsmanager_secret" "kubescape-account" {
  name = "govuk/kubescape"
}

data "aws_secretsmanager_secret_version" "kubescape-account-guid" {
  secret_id = data.aws_secretsmanager_secret.kubescape-account.id
}

resource "helm_release" "kubescape" {
  chart            = "armo-cluster-components"
  name             = "armo"
  namespace        = "armo-system"
  create_namespace = true
  repository       = "https://armosec.github.io/armo-helm/"
  version          = "1.7.6"
  set {
    name  = "clusterName"
    value = "govuk-${var.govuk_environment}"
  }
  set {
    name  = "accountGuid"
    value = jsondecode(data.aws_secretsmanager_secret_version.kubescape-account-guid.secret_string)["accountGuid"]
  }
  wait          = false
  wait_for_jobs = false
}
