# logging.tf manages EFK Stack (Elasticsearch, Fluent-Bit, Kibana).
# NOTE: Kibana and Elasticsearch will in future be replaced by Logit.

locals {
  fluentbit_service_account_name = "fluentbit"
  logging_namespace              = "logging"

  fluentbit_output = <<-OUTPUT
  [OUTPUT]
      Name es
      Match kube.*
      Host elasticsearch-master
      Logstash_Format On
      Retry_Limit False

  [OUTPUT]
      Name es
      Match host.*
      Host elasticsearch-master
      Logstash_Format On
      Logstash_Prefix node
      Retry_Limit False
  OUTPUT
}

resource "helm_release" "fluentbit" {
  name             = "fluentbit"
  repository       = "https://fluent.github.io/helm-charts"
  chart            = "fluent-bit"
  create_namespace = true
  version          = "0.16.2" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = local.logging_namespace
  values = [yamlencode({
    clusterName = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_id
    config = {
      outputs = local.fluentbit_output
    }
  })]
}

resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "7.14.0"
  namespace  = local.logging_namespace
  depends_on = [helm_release.fluentbit]
}

resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = "7.14.0"
  namespace  = local.logging_namespace
  depends_on = [helm_release.fluentbit]
}
