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
    tty                               = true,
    "customRules.execve_audit\\.yaml" = <<-EOT
      - rule: Audit Shell Commands
        desc: Audit all shell commands executed in containers
        condition: >
          container.id != host and
          evt.type = execve and
          proc.args exists
        output: >
          Shell command executed (user=%user.name container=%container.name shell=%proc.name parent=%proc.pname cmdline=%proc.cmdline)
        priority: NOTICE
        source: syscall
        tags: [exec, process]
    EOT

    # # Fix schema validation for file_output
    # {
    #   name  = "falco.file_output.enabled"
    #   value = "true"
    # }
  })]



  depends_on = [kubernetes_namespace_v1.falco]
}

