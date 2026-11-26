locals {

  prometheus_crd_yamls = {
    alertmanager_configs = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${var.prometheus_operator_crd_version}/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml"
    alertmanagers        = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${var.prometheus_operator_crd_version}/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml"
    podmonitors          = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${var.prometheus_operator_crd_version}/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml"
    probes               = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${var.prometheus_operator_crd_version}/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml"
    prometheusagents     = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${var.prometheus_operator_crd_version}/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml"
    prometheuses         = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${var.prometheus_operator_crd_version}/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml"
    prometheusrules      = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${var.prometheus_operator_crd_version}/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml"
    scrapeconfigs        = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${var.prometheus_operator_crd_version}/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml"
    servicemonitors      = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${var.prometheus_operator_crd_version}/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml"
  }
}

data "http" "prometheus_crd_yamls" {
  for_each = local.prometheus_crd_yamls
  url      = each.value
}

# Prometheus crd yaml pulled from kube-prometheus-stack helm chart.
# Update local variable `prometheus_operator_crd_version` to manage the crd version
resource "kubectl_manifest" "prometheus_operator_crds" {
  server_side_apply = true
  for_each          = data.http.prometheus_crd_yamls
  yaml_body         = each.value["response_body"]
}
