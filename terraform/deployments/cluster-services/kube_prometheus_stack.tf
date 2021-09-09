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
        pathType = "Prefix"
        annotations = {
          "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
          "alb.ingress.kubernetes.io/target-type" = "ip"
          "kubernetes.io/ingress.class"           = "alb"
        }
      }
    }
    grafana = {
      ingress = {
        enabled = true
        annotations = {
          "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
          "alb.ingress.kubernetes.io/target-type" = "ip"
          "kubernetes.io/ingress.class"           = "alb"
        }
      }
    }
    prometheus = {
      ingress = {
        enabled  = true
        pathType = "Prefix"
        annotations = {
          "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
          "alb.ingress.kubernetes.io/target-type" = "ip"
          "kubernetes.io/ingress.class"           = "alb"
        }
      }
    }
  })]
}
