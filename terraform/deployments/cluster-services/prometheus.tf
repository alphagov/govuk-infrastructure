# Installs Prometheus server, alertmanager, kube-state-metrics, node-exporter
# and pushgateway.
resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  create_namespace = true
  version          = "14.6.0" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = "monitoring"
}
