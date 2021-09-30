# Installs Prometheus Operator, Prometheus, Prometheus rules, Grafana, Grafana dashboards, and Prometheus CRDs

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  create_namespace = true
  version          = "18.0.5" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = "monitoring"
  values = [yamlencode({
    alertmanager = {
      ingress = {
        enabled  = true
        hosts    = ["alertmanager.${local.external_dns_zone_name}"]
        pathType = "Prefix"
        annotations = merge(local.alb_ingress_annotations, {
          "alb.ingress.kubernetes.io/load-balancer-name" = "alertmanager"
        })
      }
    }
    grafana = {
      ingress = {
        enabled  = true
        hosts    = ["grafana.${local.external_dns_zone_name}"]
        pathType = "Prefix"
        annotations = merge(local.alb_ingress_annotations, {
          "alb.ingress.kubernetes.io/load-balancer-name" = "grafana"
        })
      }
    }
    prometheus = {
      ingress = {
        enabled  = true
        hosts    = ["prometheus.${local.external_dns_zone_name}"]
        pathType = "Prefix"
        annotations = merge(local.alb_ingress_annotations, {
          "alb.ingress.kubernetes.io/load-balancer-name" = "prometheus"
        })
      }
      prometheusSpec = {
        # Allow empty ruleSelector (https://github.com/prometheus-community/helm-charts/blob/2cacc16807caedc6cabf1606db27e0d78c844564/charts/kube-prometheus-stack/templates/prometheus/prometheus.yaml#L202)
        ruleSelectorNilUsesHelmValues = false
      }
    }
  })]
}
