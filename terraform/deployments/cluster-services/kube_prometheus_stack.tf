# Installs Prometheus Operator, Prometheus, Prometheus rules, Grafana, Grafana dashboards, and Prometheus CRDs

locals {
  alert_manager_host = "alertmanager.${local.external_dns_zone_name}"
  grafana_host       = "grafana.${local.external_dns_zone_name}"
  prometheus_host    = "prometheus.${local.external_dns_zone_name}"
}


resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "19.2.3" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = "monitoring"
  create_namespace = true
  values = [yamlencode({
    alertmanager = {
      ingress = {
        enabled  = true
        hosts    = [local.alert_manager_host]
        pathType = "Prefix"
        annotations = merge(local.alb_ingress_annotations, {
          "alb.ingress.kubernetes.io/load-balancer-name" = "alertmanager"
        })
      }
    }
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
          name                = "GitHub"
          enabled             = true
          allow_sign_up       = true
          auth_url            = "https://${local.dex_host}/auth"
          token_url           = "https://${local.dex_host}/token"
          api_url             = "https://${local.dex_host}/userinfo"
          scopes              = "openid profile email groups"
          role_attribute_path = "to_string('Admin')" #TODO: map users/groups to different Grafana roles, e.g. Admin, Viewer, Editor
        }
        server = {
          domain   = local.grafana_host
          root_url = "https://%(domain)s"
        }
      }
      envValueFrom = {
        "GF_AUTH_GENERIC_OAUTH_CLIENT_ID" = {
          secretKeyRef = {
            name = "govuk-dex-grafana"
            key  = "GRAFANA_CLIENT_ID"
          }
        },
        "GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET" = {
          secretKeyRef = {
            name = "govuk-dex-grafana"
            key  = "GRAFANA_CLIENT_SECRET"
          }
        }
      }
    }
    prometheus = {
      ingress = {
        enabled  = true
        hosts    = [local.prometheus_host]
        pathType = "Prefix"
        annotations = merge(local.alb_ingress_annotations, {
          "alb.ingress.kubernetes.io/load-balancer-name" = "prometheus"
        })
      }
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
        # Allow empty ruleSelector (https://github.com/prometheus-community/helm-charts/blob/2cacc16807caedc6cabf1606db27e0d78c844564/charts/kube-prometheus-stack/templates/prometheus/prometheus.yaml#L202)
        ruleSelectorNilUsesHelmValues = false
      }
    }
  })]
}
