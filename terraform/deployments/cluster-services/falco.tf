resource "kubernetes_namespace_v1" "falco" {
  metadata {
    name = "falco"
    annotations = {
      "argocd.argoproj.io/sync-options" = "ServerSideApply=true"
    }
    labels = {
      "app.kubernetes.io/managed-by"  = "Terraform"
      "argocd.argoproj.io/managed-by" = "cluster-services"
      # https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/pod_readiness_gate/
      "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled"
      "pod-security.kubernetes.io/audit"        = "privileged"
      "pod-security.kubernetes.io/enforce"      = "privileged"
      "pod-security.kubernetes.io/warn"         = "privileged"
    }
  }
}

resource "helm_release" "falco" {
  name             = "falco"
  repository       = "https://falcosecurity.github.io/charts"
  chart            = "falco"
  version          = "8.0.0"
  namespace        = "falco"
  create_namespace = false

  values = [yamlencode({
    env = [
      {
        name  = "tty"
        value = true
      }
    ]
  })]

  depends_on = [kubernetes_namespace_v1.falco]
}

