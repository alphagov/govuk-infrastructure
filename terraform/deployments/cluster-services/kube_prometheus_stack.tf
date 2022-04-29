# Installs Prometheus Operator, Prometheus, Prometheus rules, Grafana, Grafana dashboards, and Prometheus CRDs

locals {
  alert_manager_host         = "alertmanager.${local.external_dns_zone_name}"
  grafana_host               = "grafana.${local.external_dns_zone_name}"
  prometheus_host            = "prometheus.${local.external_dns_zone_name}"
  grafana_iam_role           = data.terraform_remote_state.cluster_infrastructure.outputs.grafana_iam_role_arn
  prometheus_internal_url    = "http://kube-prometheus-stack-prometheus:9090"
  alert_manager_internal_url = "http://kube-prometheus-stack-alertmanager:9093"
}

resource "helm_release" "prometheus_oauth2_proxy" {
  name             = "prometheus-oauth2-proxy"
  repository       = "https://oauth2-proxy.github.io/manifests"
  chart            = "oauth2-proxy"
  version          = "6.2.0" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = local.monitoring_ns
  create_namespace = true

  values = [yamlencode({
    ingress = {
      enabled  = true
      pathType = "Prefix"
      hosts    = [local.prometheus_host]
      annotations = merge(local.alb_ingress_annotations, {
        "alb.ingress.kubernetes.io/load-balancer-name" = "prometheus"
      })
    }

    proxyVarsAsSecrets = false

    extraArgs = { "skip-provider-button" = "true" }
    extraEnv = [
      {
        name  = "OAUTH2_PROXY_UPSTREAMS"
        value = local.prometheus_internal_url
      },
      {
        name  = "OAUTH2_PROXY_PROVIDER"
        value = "oidc"
      },
      {
        name  = "OAUTH2_PROXY_PROVIDER_DISPLAY_NAME"
        value = "GitHub"
      },
      {
        name  = "OAUTH2_PROXY_OIDC_ISSUER_URL"
        value = "https://${local.dex_host}"
      },
      { # Only one role is supported so only admins will be able access Prometheus UI
        name  = "OAUTH2_PROXY_ALLOWED_GROUP"
        value = var.github_read_write_team
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
    ]
  })]
}

resource "helm_release" "alertmanager_oauth2_proxy" {
  name             = "alertmanager-oauth2-proxy"
  repository       = "https://oauth2-proxy.github.io/manifests"
  chart            = "oauth2-proxy"
  version          = "6.2.0" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = local.monitoring_ns
  create_namespace = true

  values = [yamlencode({
    ingress = {
      enabled  = true
      pathType = "Prefix"
      hosts    = [local.alert_manager_host]
      annotations = merge(local.alb_ingress_annotations, {
        "alb.ingress.kubernetes.io/load-balancer-name" = "alertmanager"
      })
    }

    proxyVarsAsSecrets = false

    extraArgs = { "skip-provider-button" = "true" }
    extraEnv = [
      {
        name  = "OAUTH2_PROXY_UPSTREAMS"
        value = local.alert_manager_internal_url
      },
      {
        name  = "OAUTH2_PROXY_PROVIDER"
        value = "oidc"
      },
      {
        name  = "OAUTH2_PROXY_PROVIDER_DISPLAY_NAME"
        value = "GitHub"
      },
      {
        name  = "OAUTH2_PROXY_OIDC_ISSUER_URL"
        value = "https://${local.dex_host}"
      },
      { # Only one role is supported so only admins will be able access Alert Manager UI
        name  = "OAUTH2_PROXY_ALLOWED_GROUP"
        value = var.github_read_write_team
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
    ]
  })]
}

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "34.9.0" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = local.monitoring_ns
  create_namespace = true
  values = [yamlencode({
    grafana = {
      ingress = {
        enabled  = true
        hosts    = [local.grafana_host]
        pathType = "Prefix"
        annotations = merge(local.alb_ingress_annotations, {
          "alb.ingress.kubernetes.io/load-balancer-name" = "grafana"
        })
      }
      "grafana.ini" = {
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
      }
    }
  })]
}
