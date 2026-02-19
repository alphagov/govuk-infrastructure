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

resource "helm_release" "tetragon" {
  name       = "tetragon"
  repository = "https://helm.cilium.io"
  chart      = "tetragon"
  version    = "1.6.0"
  namespace  = kubernetes_namespace_v1.tetragon.id

  values = [yamlencode({
    tetragon = {
      exportAllowList = jsonencode({ "in_init_tree" : false, "namespace" : ["apps"], "event_set" : ["PROCESS_EXEC", "PROCESS_EXIT", "PROCESS_KPROBE", "PROCESS_UPROBE", "PROCESS_TRACEPOINT", "PROCESS_LSM"] })
      exportDenyList  = <<EOF
        {"health_check":true}
        {"namespace":["", "kube-system"]}
      EOF
      exportFilePerm  = "644"
    }
    export = {
      mode = ""
    }
  })]
}
