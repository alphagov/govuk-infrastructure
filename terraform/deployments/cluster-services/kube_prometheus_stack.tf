# Installs Prometheus Operator, Prometheus, Prometheus rules, Grafana, Grafana dashboards, and Prometheus CRDs

locals {
  dns_zone_name = trimsuffix(data.terraform_remote_state.cluster_infrastructure.outputs.external_dns_zone_name, ".")
}

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
        hosts    = ["alertmanager.${local.dns_zone_name}"]
        pathType = "Prefix"
        annotations = {
          "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
          "alb.ingress.kubernetes.io/target-type" = "ip"
        }
      }
    }
    grafana = {
      ingress = {
        enabled  = true
        hosts    = ["grafana.${local.dns_zone_name}"]
        pathType = "Prefix"
        annotations = {
          "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
          "alb.ingress.kubernetes.io/target-type" = "ip"
        }
      }
    }
    prometheus = {
      ingress = {
        enabled  = true
        hosts    = ["prometheus.${local.dns_zone_name}"]
        pathType = "Prefix"
        annotations = {
          "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
          "alb.ingress.kubernetes.io/target-type" = "ip"
        }
      }
    }
  })]
}
