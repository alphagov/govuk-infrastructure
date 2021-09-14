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
    }
  })]
}
