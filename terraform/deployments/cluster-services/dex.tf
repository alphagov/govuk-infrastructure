# Installs and configures Dex, a federated OpenID Connect provider

locals {
  dex_host = "dex.${local.external_dns_zone_name}"
}

resource "helm_release" "dex" {
  depends_on       = [helm_release.aws_lb_controller, helm_release.cluster_secrets]
  chart            = "dex"
  name             = "dex"
  namespace        = local.services_ns
  create_namespace = true
  repository       = "https://charts.dexidp.io"
  version          = "0.9.0" # TODO: Dependabot or equivalent so this doesn't get neglected.
  values = [yamlencode({
    replicaCount = var.desired_ha_replicas
    config = {
      issuer = "https://${local.dex_host}"

      oauth2 = {
        skipApprovalScreen = true
      }

      storage = {
        type = "kubernetes"
        config = {
          inCluster = true
        }
      }

      connectors = [
        {
          type = "github"
          id   = "github"
          name = "GitHub"
          config = {
            clientID      = "$GITHUB_CLIENT_ID"
            clientSecret  = "$GITHUB_CLIENT_SECRET"
            redirectURI   = "https://${local.dex_host}/callback"
            orgs          = var.dex_github_orgs_teams
            teamNameField = "both"
            useLoginAsID  = true
          }
        }
      ]

      # staticClients uses a different method for expansion of environment
      # variables, see [bug](https://github.com/gabibbo97/charts/issues/36#issuecomment-736911424)
      staticClients = [
        {
          name         = "argo-workflows"
          idEnv        = "ARGO_WORKFLOWS_CLIENT_ID"
          secretEnv    = "ARGO_WORKFLOWS_CLIENT_SECRET"
          redirectURIs = ["https://${local.argo_workflows_host}/oauth2/callback"]
        },
        {
          name         = "argocd"
          idEnv        = "ARGOCD_CLIENT_ID"
          secretEnv    = "ARGOCD_CLIENT_SECRET"
          redirectURIs = ["https://${local.argo_host}/auth/callback"]
        },
        {
          name         = "grafana"
          idEnv        = "GRAFANA_CLIENT_ID"
          secretEnv    = "GRAFANA_CLIENT_SECRET"
          redirectURIs = ["https://${local.grafana_host}/login/generic_oauth"]
        },
        {
          name         = "prometheus"
          idEnv        = "PROMETHEUS_CLIENT_ID"
          secretEnv    = "PROMETHEUS_CLIENT_SECRET"
          redirectURIs = ["https://${local.prometheus_host}/oauth2/callback"]
        },
        {
          name         = "alert-manager"
          idEnv        = "ALERT_MANAGER_CLIENT_ID"
          secretEnv    = "ALERT_MANAGER_CLIENT_SECRET"
          redirectURIs = ["https://${local.alertmanager_host}/oauth2/callback"]
        }
      ]
    }

    envVars = [
      {
        name = "GITHUB_CLIENT_ID"
        valueFrom = {
          secretKeyRef = {
            name = "govuk-dex-github"
            key  = "clientID"
          }
        }
      },
      {
        name = "GITHUB_CLIENT_SECRET"
        valueFrom = {
          secretKeyRef = {
            name = "govuk-dex-github"
            key  = "clientSecret"
          }
        }
      },
      {
        name = "ARGO_WORKFLOWS_CLIENT_ID"
        valueFrom = {
          secretKeyRef = {
            name = "govuk-dex-argo-workflows"
            key  = "clientID"
          }
        }
      },
      {
        name = "ARGO_WORKFLOWS_CLIENT_SECRET"
        valueFrom = {
          secretKeyRef = {
            name = "govuk-dex-argo-workflows"
            key  = "clientSecret"
          }
        }
      },
      {
        name = "ARGOCD_CLIENT_ID"
        valueFrom = {
          secretKeyRef = {
            name = "govuk-dex-argocd"
            key  = "clientID"
          }
        }
      },
      {
        name = "ARGOCD_CLIENT_SECRET"
        valueFrom = {
          secretKeyRef = {
            name = "govuk-dex-argocd"
            key  = "clientSecret"
          }
        }
      },
      {
        name = "GRAFANA_CLIENT_ID"
        valueFrom = {
          secretKeyRef = {
            name = "govuk-dex-grafana"
            key  = "clientID"
          }
        }
      },
      {
        name = "GRAFANA_CLIENT_SECRET"
        valueFrom = {
          secretKeyRef = {
            name = "govuk-dex-grafana"
            key  = "clientSecret"
          }
        }
      },
      {
        name = "PROMETHEUS_CLIENT_ID"
        valueFrom = {
          secretKeyRef = {
            name = "govuk-dex-prometheus"
            key  = "clientID"
          }
        }
      },
      {
        name = "PROMETHEUS_CLIENT_SECRET"
        valueFrom = {
          secretKeyRef = {
            name = "govuk-dex-prometheus"
            key  = "clientSecret"
          }
        }
      },
      {
        name = "ALERT_MANAGER_CLIENT_ID"
        valueFrom = {
          secretKeyRef = {
            name = "govuk-dex-alertmanager"
            key  = "clientID"
          }
        }
      },
      {
        name = "ALERT_MANAGER_CLIENT_SECRET"
        valueFrom = {
          secretKeyRef = {
            name = "govuk-dex-alertmanager"
            key  = "clientSecret"
          }
        }
      }
    ]

    service = {
      ports = {
        http = {
          port = 80
        }
        https = {
          port = 443
        }
      }
    }

    ingress = {
      enabled = true
      annotations = {
        "alb.ingress.kubernetes.io/group.name"         = "dex"
        "alb.ingress.kubernetes.io/scheme"             = "internet-facing"
        "alb.ingress.kubernetes.io/target-type"        = "ip"
        "alb.ingress.kubernetes.io/load-balancer-name" = "dex"
        "alb.ingress.kubernetes.io/listen-ports"       = jsonencode([{ "HTTP" : 80 }, { "HTTPS" : 443 }])
        "alb.ingress.kubernetes.io/ssl-redirect"       = "443"
      }
      className = "aws-alb"
      hosts = [
        {
          host = local.dex_host
          paths = [
            {
              path     = "/*"
              pathType = "ImplementationSpecific"
            }
          ]
        }
      ]
    }
  })]
}
