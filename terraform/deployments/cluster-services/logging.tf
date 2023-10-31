# logging.tf manages Filebeat, which ships logs to Logit.io, a managed ELK stack.

resource "helm_release" "filebeat" {
  depends_on = [helm_release.cluster_secrets]

  name       = "filebeat"
  repository = "https://helm.elastic.co"
  chart      = "filebeat"
  # TODO: stop using this unmaintained chart by updating to filebeat v8 (final
  # version of the deprecated chart), then switching to the eck-beats operator:
  # https://github.com/elastic/cloud-on-k8s/blob/main/deploy/eck-stack/charts/eck-beats/Chart.yaml
  version          = "8.5.1"
  namespace        = local.services_ns
  create_namespace = true
  values = [yamlencode({
    daemonset = { secretMounts = [] }
    filebeatConfig = {
      "filebeat.yml" = yamlencode(yamldecode(file("${path.module}/filebeat.yml")))
    }
    imageTag = "8.10.4" # TODO: Dependabot or equivalent so this doesn't get neglected.
    clusterRoleRules = [
      {
        apiGroups = [""]
        resources = ["namespaces", "nodes", "pods"]
        verbs     = ["get", "list", "watch"]
      },
      {
        apiGroups = ["apps"]
        resources = ["replicasets"]
        verbs     = ["get", "list", "watch"]
      },
      {
        apiGroups = ["batch"]
        resources = ["jobs"]
        verbs     = ["get", "list", "watch"]
      }
    ]
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
