# Installs Grafana.
# NOTE: Dashboards should *not* be configured in cluster-services.
#       Dashboards are user-supplied data and are deployed independently.

resource "helm_release" "grafana" {
  name             = "grafana"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  create_namespace = true
  version          = "6.16.2" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = "monitoring"
  timeout          = 60 # seconds
  values = [yamlencode({
    datasources = {
      "datasources.yaml" = {
        apiVersion = 1
        datasources = [
          {
            name            = "Prometheus"
            type            = "prometheus"
            access          = "proxy"
            url             = "prometheus-server"
            withCredentials = false
            isDefault       = true
            version         = 1
            editable        = true
          },
          {
            name            = "Elasticsearch"
            type            = "elasticsearch"
            access          = "proxy"
            url             = "elasticsearch-master.${local.logging_namespace}:9200"
            withCredentials = false
            isDefault       = false
            version         = 1
            editable        = true
          }
        ]
      }
    }
  })]
}
