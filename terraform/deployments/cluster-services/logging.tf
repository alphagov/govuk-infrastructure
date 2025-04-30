# logging.tf manages Filebeat, which ships logs to Logit.io, a managed ELK stack.

resource "helm_release" "filebeat" {
  # don't install in ephemeral environments
  count = startswith(var.govuk_environment, "eph-") ? 0 : 1

  name       = "filebeat"
  repository = "https://helm.elastic.co"
  chart      = "filebeat"
  # TODO: stop using this unmaintained chart by updating to filebeat v8 (final
  # version of the deprecated chart), then switching to the eck-beats operator:
  # https://github.com/elastic/cloud-on-k8s/blob/main/deploy/eck-stack/charts/eck-beats/Chart.yaml
  version          = "8.5.1"
  namespace        = local.services_ns
  create_namespace = true
  timeout          = var.helm_timeout_seconds
  values = [yamlencode({
    daemonset = {
      securityContext = {
        allowPrivilegeEscalation = false
        privileged               = false
        runAsUser                = 1000
        runAsNonRoot             = true
        runAsGroup               = 1000
        capabilities = {
          add  = ["DAC_READ_SEARCH"]
          drop = ["ALL"]
        }
      }
      secretMounts = []
      tolerations = [{ # TODO: remove once we no longer run amd64 (Intel) nodes.
        key      = "arch"
        operator = "Equal"
        value    = "arm64"
        effect   = "NoSchedule"
      }]
    }
    filebeatConfig = {
      "filebeat.yml" = yamlencode(yamldecode(file("${path.module}/filebeat.yml")))
    }
    imageTag = "8.14.1" # TODO: Dependabot or equivalent so this doesn't get neglected.
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
