# logging.tf manages Filebeat, which ships logs to Logit, a managed ELK stack.

resource "helm_release" "filebeat" {
  depends_on = [helm_release.cluster_secrets]

  name             = "filebeat"
  repository       = "https://helm.elastic.co"
  chart            = "filebeat"
  version          = "7.7.1" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = local.services_ns
  create_namespace = true
  values = [yamlencode({
    filebeatConfig = {
      "filebeat.yml" = yamlencode({
        "filebeat.inputs" = [
          {
            type  = "container"
            paths = ["/var/lib/docker/containers/*/*.log"]
            processors = [{
              add_kubernetes_metadata = {
                host = "$${NODE_NAME}"
                matchers = [{
                  logs_path = {
                    logs_path = "/var/lib/docker/containers/"
                  }
                }]
              }
            }]
          }
        ]

        "output.logstash" : {
          "hosts" : ["$${LOGSTASH_HOST:? LOGSTASH_HOST variable is not set}:18998"]
          "loadbalance" : true
          "ssl.enabled" : true
        }
      })
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
      }
    ]
  })]
}
