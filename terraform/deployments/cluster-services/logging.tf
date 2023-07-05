# logging.tf manages Filebeat, which ships logs to Logit, a managed ELK stack.

resource "helm_release" "filebeat" {
  depends_on = [helm_release.cluster_secrets]

  name             = "filebeat"
  repository       = "https://helm.elastic.co"
  chart            = "filebeat"
  version          = "7.17.3" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = local.services_ns
  create_namespace = true
  values = [yamlencode({
    filebeatConfig = {
      "filebeat.yml" = yamlencode({
        processors = [
          {
            drop_fields = {
              ignore_missing = true
              fields = [
                "agent",
              ]
            }
          },
        ]
        "filebeat.inputs" = [
          {
            type  = "container"
            paths = ["/var/log/containers/*.log"]
            processors = [
              {
                add_kubernetes_metadata = {
                  host = "$${NODE_NAME}"
                  matchers = [{
                    logs_path = { logs_path = "/var/log/containers/" }
                  }]
                }
              },
              {
                drop_fields = {
                  ignore_missing = true
                  fields = [
                    "log",
                    "kubernetes.labels.app", # Prefer app_kubernetes_io/name.
                    "kubernetes.labels.app_kubernetes_io/managed-by",
                    "kubernetes.labels.pod-template-hash",
                    "kubernetes.namespace_labels",
                    "kubernetes.namespace_uid",
                    "kubernetes.node.hostname",
                    "kubernetes.node.labels.beta_kubernetes_io/arch",
                    "kubernetes.node.labels.beta_kubernetes_io/instance-type",
                    "kubernetes.node.labels.beta_kubernetes_io/os",
                    "kubernetes.node.labels.eks_amazonaws_com/nodegroup",
                    "kubernetes.node.labels.eks_amazonaws_com/nodegroup-image",
                    "kubernetes.node.labels.failure-domain_beta_kubernetes_io/region",
                    "kubernetes.node.labels.failure-domain_beta_kubernetes_io/zone",
                    "kubernetes.node.labels.k8s_io/cloud-provider-aws",
                    "kubernetes.node.labels.kubernetes_io/hostname",
                    "kubernetes.node.labels.kubernetes_io/os",
                    "kubernetes.node.labels.topology_ebs_csi_aws_com/zone",
                    "kubernetes.node.labels.topology_kubernetes_io/region",
                    "kubernetes.node.uid",
                    "kubernetes.pod.uid",
                    "kubernetes.replicaset",
                  ]
                }
              },
            ]
          }
        ]
        "output.logstash" = {
          hosts         = ["$${LOGSTASH_HOST:? LOGSTASH_HOST variable is not set}:$${LOGSTASH_PORT:? LOGSTASH_PORT variable is not set}"]
          loadbalance   = true
          "ssl.enabled" = true
        }
        "http.enabled"            = false
        "logging.metrics.enabled" = false
        "logging.level"           = "warning"
        "output.file"             = { "enabled" = false }
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
