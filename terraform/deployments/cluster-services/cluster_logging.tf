# cluster_logging.tf manages Filebeat, which ships cluster-level logs to Logit

resource "helm_release" "cluster_filebeat" {
  depends_on = [helm_release.cluster_secrets]

  name             = "cluster_filebeat"
  repository       = "https://helm.elastic.co"
  chart            = "filebeat"
  version          = "7.15.0" # TODO: Make sure this doesn't get neglected
  namespace        = local.services_ns
  create_namespace = true
  values = [
    yamlencode(
      {
        daemonset = {
          enabled = false
        }
        deployment = {
          enabled   = true
          runAsUser = 1
          filebeatConfig = {
            "filebeat.yml" = yamlencode({
              "filebeat.inputs" = [
                {
                  type           = "aws-cloudwatch"
                  log_group_arn  = "arn:aws:logs:eu-west-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/eks/govuk/cluster"
                  scan_frequency = "30s"
                  start_position = "end"
                }
              ]
              "output.elasticsearch" = {
                hosts         = ["$${LOGSTASH_HOST:? LOGSTASH_HOST variable is not set}:$${LOGSTASH_PORT:? LOGSTASH_PORT variable is not set}"]
                loadbalance   = true
                "ssl.enabled" = true
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
        }
        managedServiceAccount = false
        serviceAccount        = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_logging_service_account_name
        serviceAccountAnnotations = {
          "eks.amazonaws.com/role-arn" = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_logging_role_arn
        }
        replicas = 1
      }
    )
  ]
}
