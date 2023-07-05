# logging.tf manages Filebeat, which ships logs to Logit.io, a managed ELK stack.

resource "helm_release" "filebeat" {
  depends_on = [helm_release.cluster_secrets]

  name       = "filebeat"
  repository = "https://helm.elastic.co"
  chart      = "filebeat"
  # TODO: stop using this unmaintained chart by updating to filebeat v8 (final
  # version of the deprecated chart), then switching to the eck-beats operator:
  # https://github.com/elastic/cloud-on-k8s/blob/main/deploy/eck-stack/charts/eck-beats/Chart.yaml
  version          = "7.17.3" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = local.services_ns
  create_namespace = true
  values = [yamlencode({
    filebeatConfig = {
      "filebeat.yml" = yamlencode(yamldecode(file("${path.module}/filebeat.yml")))
    }
    extraEnvs = [
      {
        name = "LOGSTASH_HOST"
        valueFrom = {
          secretKeyRef = {
            name = "logit-host"
            key  = "host"
          }
        }
      },
      {
        name = "LOGSTASH_PORT"
        valueFrom = {
          secretKeyRef = {
            name = "logit-host"
            key  = "port"
          }
        }
      }
    ]
  })]
}
