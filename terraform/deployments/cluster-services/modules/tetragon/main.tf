resource "kubernetes_namespace_v1" "tetragon" {
  metadata {
    name = local.tetragon_namespace
    annotations = {
      "argocd.argoproj.io/sync-options" = "ServerSideApply=true"
    }
    labels = {
      "app.kubernetes.io/managed-by"       = "Terraform"
      "argocd.argoproj.io/managed-by"      = "cluster-services"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}
