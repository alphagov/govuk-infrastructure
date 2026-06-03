resource "kubernetes_namespace_v1" "loki" {
  metadata {
    name = "loki"
  }
}

locals {
  loki_helm_chart_values = templatefile(
    "./files/loki_helm_values.tpl.yaml",
    {
      iam_role_arn      = aws_iam_role.loki.arn,
      aws_region        = "eu-west-1",
      chunk_bucket_name = module.s3_bucket_chunks.name,
      ruler_bucket_name = module.s3_bucket_ruler.name,
      alert_manager_url = "http://kube-prometheus-stack-alertmanager.monitoring.svc.cluster.local:9093", // FIXME
    }
  )
}

resource "helm_release" "loki" {
  chart            = "loki"
  name             = "loki"
  namespace        = kubernetes_namespace_v1.loki.id
  create_namespace = false
  repository       = "https://grafana-community.github.io/helm-charts"
  version          = "17.1.6"
  timeout          = 300
  values           = [local.loki_helm_chart_values]
}
