# Installs Prometheus Operator, Prometheus, Prometheus rules, Grafana (with
# some default dashboards) and Prometheus CRDs.

data "aws_secretsmanager_secret" "alertmanager-pagerduty" {
  name = "govuk/alertmanager/pagerduty-routing-key"
}

data "aws_secretsmanager_secret_version" "alertmanager-pagerduty" {
  secret_id = data.aws_secretsmanager_secret.alertmanager-pagerduty.id
}

data "aws_secretsmanager_secret" "alertmanager-slack" {
  name = "govuk/slack-webhook-url"
}

data "aws_secretsmanager_secret_version" "alertmanager-slack" {
  secret_id = data.aws_secretsmanager_secret.alertmanager-slack.id
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

resource "random_password" "grafana_admin" { length = 24 }

resource "helm_release" "prometheus_oauth2_proxy" {
  depends_on       = [helm_release.dex]
  name             = "prometheus-oauth2-proxy"
  repository       = "https://oauth2-proxy.github.io/manifests"
  chart            = "oauth2-proxy"
  version          = "6.18.0" # TODO: Dependabot or equivalent so this doesn't get neglected.
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
  version          = "6.18.0" # TODO: Dependabot or equivalent so this doesn't get neglected.
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
