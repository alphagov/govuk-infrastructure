# Installs Prometheus Operator, Prometheus, Prometheus rules, Grafana, Grafana dashboards, and Prometheus CRDs

data "aws_secretsmanager_secret" "alertmanager-pagerduty" {
  name = "govuk/alertmanager/pagerduty-routing-key"
}

data "aws_secretsmanager_secret_version" "alertmanager-pagerduty" {
  secret_id = data.aws_secretsmanager_secret.alertmanager-pagerduty.id
}

locals {
  alertmanager_host         = "alertmanager.${local.external_dns_zone_name}"
  grafana_host              = "grafana.${local.external_dns_zone_name}"
  prometheus_host           = "prometheus.${local.external_dns_zone_name}"
  grafana_iam_role          = data.terraform_remote_state.cluster_infrastructure.outputs.grafana_iam_role_arn
  prometheus_internal_url   = "http://kube-prometheus-stack-prometheus:9090"
  alertmanager_internal_url = "http://kube-prometheus-stack-alertmanager:9093"
  oauth2_proxy_extra_env = [for k, v in {
    # Only one role is supported, so only admins can access Prometheus/Alertmanager UI.
    "OAUTH2_PROXY_ALLOWED_GROUP"         = var.github_read_write_team
    "OAUTH2_PROXY_OIDC_ISSUER_URL"       = "https://${local.dex_host}"
    "OAUTH2_PROXY_PROVIDER"              = "oidc"
    "OAUTH2_PROXY_PROVIDER_DISPLAY_NAME" = "GitHub"
  } : { name = k, value = v }]
}

resource "helm_release" "prometheus_oauth2_proxy" {
  depends_on       = [helm_release.dex]
  name             = "prometheus-oauth2-proxy"
  repository       = "https://oauth2-proxy.github.io/manifests"
  chart            = "oauth2-proxy"
  version          = "6.9.1" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = local.monitoring_ns
  create_namespace = true

  values = [yamlencode({
    proxyVarsAsSecrets = false
    ingress = {
      enabled  = true
      pathType = "Prefix"
      hosts    = [local.prometheus_host]
      annotations = merge(local.alb_ingress_annotations, {
        "alb.ingress.kubernetes.io/load-balancer-name" = "prometheus"
      })
    }
    extraArgs = { "skip-provider-button" = "true" }
    extraEnv = concat(local.oauth2_proxy_extra_env, [
      {
        name  = "OAUTH2_PROXY_UPSTREAMS"
        value = local.prometheus_internal_url
      },
      {
        name = "OAUTH2_PROXY_CLIENT_ID"
        valueFrom = {
          secretKeyRef = {
            name = "govuk-dex-prometheus"
            key  = "clientID"
          }
        }
      },
      {
        name = "OAUTH2_PROXY_CLIENT_SECRET"
        valueFrom = {
          secretKeyRef = {
            name = "govuk-dex-prometheus"
            key  = "clientSecret"
          }
        }
      },
      {
        name = "OAUTH2_PROXY_COOKIE_SECRET"
        valueFrom = {
          secretKeyRef = {
            name = "govuk-dex-prometheus"
            key  = "cookieSecret"
          }
        }
      }
    ])
  })]
}

resource "helm_release" "alertmanager_oauth2_proxy" {
  depends_on       = [helm_release.dex]
  name             = "alertmanager-oauth2-proxy"
  repository       = "https://oauth2-proxy.github.io/manifests"
  chart            = "oauth2-proxy"
  version          = "6.9.1" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = local.monitoring_ns
  create_namespace = true

  values = [yamlencode({
    proxyVarsAsSecrets = false
    ingress = {
      enabled  = true
      pathType = "Prefix"
      hosts    = [local.alertmanager_host]
      annotations = merge(local.alb_ingress_annotations, {
        "alb.ingress.kubernetes.io/load-balancer-name" = "alertmanager"
      })
    }
    extraArgs = { "skip-provider-button" = "true" }
    extraEnv = concat(local.oauth2_proxy_extra_env, [
      {
        name  = "OAUTH2_PROXY_UPSTREAMS"
        value = local.alertmanager_internal_url
      },
      {
        name = "OAUTH2_PROXY_CLIENT_ID"
        valueFrom = {
          secretKeyRef = {
            name = "govuk-dex-alert-manager"
            key  = "clientID"
          }
        }
      },
      {
        name = "OAUTH2_PROXY_CLIENT_SECRET"
        valueFrom = {
          secretKeyRef = {
            name = "govuk-dex-alert-manager"
            key  = "clientSecret"
          }
        }
      },
      {
        name = "OAUTH2_PROXY_COOKIE_SECRET"
        valueFrom = {
          secretKeyRef = {
            name = "govuk-dex-alert-manager"
            key  = "cookieSecret"
          }
        }
      }
    ])
  })]
}

resource "helm_release" "kube_prometheus_stack" {
  depends_on       = [helm_release.dex]
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "45.4.0" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = local.monitoring_ns
  create_namespace = true
  values = [
    templatefile("${path.module}/templates/alertmanager-config.tpl",
      {
        routing_key       = data.aws_secretsmanager_secret_version.alertmanager-pagerduty.secret_string,
        alertmanager_host = local.alertmanager_host
    }),
    yamlencode({
      grafana = {
        defaultDashboardsTimezone = "Europe/London"
        replicas                  = var.default_desired_ha_replicas
        ingress = {
          enabled  = true
          hosts    = [local.grafana_host]
          pathType = "Prefix"
          annotations = merge(local.alb_ingress_annotations, {
            "alb.ingress.kubernetes.io/load-balancer-name" = "grafana"
          })
        }
        "grafana.ini" = {
          auth = {
            oauth_auto_login = true
          },
          "auth.generic_oauth" = {
            name                  = "GitHub"
            enabled               = true
            allow_sign_up         = true
            auth_url              = "https://${local.dex_host}/auth"
            token_url             = "https://${local.dex_host}/token"
            api_url               = "https://${local.dex_host}/userinfo"
            scopes                = "openid profile email groups"
            role_attribute_path   = "contains(groups[*], '${var.github_read_write_team}') && 'Admin' || contains(groups[*], '${var.github_read_only_team}') && 'Viewer'"
            role_attribute_strict = true
          }
          server = {
            domain   = local.grafana_host
            root_url = "https://%(domain)s"
          }
          database = {
            type     = "postgres"
            ssl_mode = "disable"
          }
          date_formats = {
            interval_hour = "YYYY-MM-DD HH:mm"
            interval_day  = "YYYY-MM-DD"
          }
        }
        envValueFrom = {
          "GF_AUTH_GENERIC_OAUTH_CLIENT_ID" = {
            secretKeyRef = {
              name = "govuk-dex-grafana"
              key  = "clientID"
            }
          },
          "GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET" = {
            secretKeyRef = {
              name = "govuk-dex-grafana"
              key  = "clientSecret"
            }
          },
          "GF_DATABASE_HOST" = {
            secretKeyRef = {
              name = "govuk-grafana-database"
              key  = "host"
            }
          },
          "GF_DATABASE_USER" = {
            secretKeyRef = {
              name = "govuk-grafana-database"
              key  = "username"
            }
          },
          "GF_DATABASE_PASSWORD" = {
            secretKeyRef = {
              name = "govuk-grafana-database"
              key  = "password"
            }
          }
        }
        serviceAccount = {
          annotations = {
            "eks.amazonaws.com/role-arn" = local.grafana_iam_role
          }
        }
        env = {
          "AWS_ROLE_ARN"                = local.grafana_iam_role
          "AWS_WEB_IDENTITY_TOKEN_FILE" = "/var/run/secrets/eks.amazonaws.com/serviceaccount/token"
          "AWS_REGION"                  = data.aws_region.current.name
        }
        extraSecretMounts = [{
          name      = "aws-iam-token"
          mountPath = "/var/run/secrets/eks.amazonaws.com/serviceaccount"
          readOnly  = true
          projected = {
            defaultMode = 420 # 0644 octal
            sources = [{
              serviceAccountToken = {
                audience          = "sts.amazonaws.com"
                expirationSeconds = 86400
                path              = "token"
              }
            }]
          }
        }]
        additionalDataSources = [{
          name     = "CloudWatch"
          type     = "cloudwatch"
          access   = "proxy"
          uid      = "cloudwatch"
          editable = false
          jsonData = {
            authType      = "default"
            defaultRegion = data.aws_region.current.name
          }
        }]
      }
      alertmanager = {
        alertmanagerSpec = {
          replicas = var.default_desired_ha_replicas
          podDisruptionBudget = {
            enabled = var.default_desired_ha_replicas > 1
          }
          podAntiAffinity = var.default_desired_ha_replicas > 1 ? "hard" : ""
          storage = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "ebs-gp3"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = { storage = "10Gi" }
                }
              }
            }
          }
          externalUrl = "https://${local.alertmanager_host}"
        }
      }
      prometheus = {
        # Match all PrometheusRules cluster-wide. (If an app/team needs a separate
        # Prom instance, it almost certainly needs a separate EKS cluster too.)
        prometheusSpec = {
          ruleNamespaceSelector = {
            matchExpressions = [{
              key      = "no_monitor"
              operator = "DoesNotExist"
              values   = []
            }]
          }
          # Allow empty ruleSelector (https://github.com/prometheus-community/helm-charts/blob/2cacc16/charts/kube-prometheus-stack/templates/prometheus/prometheus.yaml#L202)
          ruleSelectorNilUsesHelmValues = false
          podMonitorNamespaceSelector = {
            matchExpressions = [{
              key      = "no_monitor"
              operator = "DoesNotExist"
              values   = []
            }]
          }
          podMonitorSelectorNilUsesHelmValues     = false
          serviceMonitorSelectorNilUsesHelmValues = false
          replicas                                = var.default_desired_ha_replicas
          podDisruptionBudget = {
            enabled = var.default_desired_ha_replicas > 1
          }
          podAntiAffinity = var.default_desired_ha_replicas > 1 ? "hard" : ""
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "ebs-gp3"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = { storage = "50Gi" }
                }
              }
            }
          }
          externalUrl = "https://${local.prometheus_host}"
        }
      }
      kube_state_metrics = {
        selfMonitor = { enabled = true }
      }
    })
  ]
}
