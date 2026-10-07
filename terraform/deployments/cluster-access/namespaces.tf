resource "kubernetes_namespace_v1" "apps" {
  metadata {
    name = var.apps_namespace
    annotations = {
      "argocd.argoproj.io/sync-options" = "ServerSideApply=true"
    }
    labels = {
      "app.kubernetes.io/managed-by"  = "Terraform"
      "argocd.argoproj.io/managed-by" = "cluster-services"
      # https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/pod_readiness_gate/
      "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled"
      "pod-security.kubernetes.io/audit"        = "restricted"
      "pod-security.kubernetes.io/enforce"      = "restricted"
      "pod-security.kubernetes.io/warn"         = "restricted"
    }
  }
}

resource "kubernetes_namespace_v1" "licensify" {
  metadata {
    name = var.licensify_namespace
    annotations = {
      "argocd.argoproj.io/sync-options" = "ServerSideApply=true"
    }
    labels = {
      "app.kubernetes.io/managed-by"  = "Terraform"
      "argocd.argoproj.io/managed-by" = "cluster-services"
      # https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/pod_readiness_gate/
      "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled"
      "pod-security.kubernetes.io/audit"        = "restricted"
      "pod-security.kubernetes.io/enforce"      = "restricted"
      "pod-security.kubernetes.io/warn"         = "restricted"
    }
  }
}

resource "kubernetes_namespace_v1" "datagovuk" {
  metadata {
    name = var.datagovuk_namespace
    annotations = {
      "argocd.argoproj.io/sync-options" = "ServerSideApply=true"
    }
    labels = {
      "app.kubernetes.io/managed-by"       = "Terraform"
      "argocd.argoproj.io/managed-by"      = "cluster-services"
      "pod-security.kubernetes.io/audit"   = "restricted"
      "pod-security.kubernetes.io/enforce" = "restricted"
      "pod-security.kubernetes.io/warn"    = "restricted"
    }
  }
}

resource "kubernetes_namespace_v1" "job-request-operator" {
  metadata {
    name = var.job_request_operator_namespace
    annotations = {
      "argocd.argoproj.io/sync-options" = "ServerSideApply=true"
    }
    labels = {
      "app.kubernetes.io/managed-by"       = "Terraform"
      "argocd.argoproj.io/managed-by"      = "cluster-services"
      "pod-security.kubernetes.io/audit"   = "restricted"
      "pod-security.kubernetes.io/enforce" = "restricted"
      "pod-security.kubernetes.io/warn"    = "restricted"
    }
  }
}

resource "kubernetes_namespace_v1" "job-request-operator-smoke-test" {
  count = var.enable_job_request_operator_smoke_test_namespace ? 1 : 0
  metadata {
    name = var.job_request_operator_smoke_test_namespace
    annotations = {
      "argocd.argoproj.io/sync-options" = "ServerSideApply=true"
    }
    labels = {
      "app.kubernetes.io/managed-by"       = "Terraform"
      "argocd.argoproj.io/managed-by"      = "cluster-services"
      "pod-security.kubernetes.io/audit"   = "restricted"
      "pod-security.kubernetes.io/enforce" = "restricted"
      "pod-security.kubernetes.io/warn"    = "restricted"
    }
  }
}

# govuk-preview-app (deployed as a normal app in `apps`, see repos.yml)
# creates ephemeral per-branch previews of other apps' own Deployments,
# Services, Jobs etc in here - integration-only, since that's the only
# environment it runs in. Its cross-namespace Role/RoleBinding into this
# namespace are shipped by its own Helm chart (govuk-helm-charts'
# charts/govuk-previews), not here - this only owns the namespace's
# existence and baseline Pod Security Standard, same division of
# responsibility as every other namespace in this file.
resource "kubernetes_namespace_v1" "previews" {
  count = var.enable_previews_namespace ? 1 : 0
  metadata {
    name = local.previews_namespace
    annotations = {
      "argocd.argoproj.io/sync-options" = "ServerSideApply=true"
    }
    labels = {
      "app.kubernetes.io/managed-by"       = "Terraform"
      "argocd.argoproj.io/managed-by"      = "cluster-services"
      "pod-security.kubernetes.io/audit"   = "restricted"
      "pod-security.kubernetes.io/enforce" = "restricted"
      "pod-security.kubernetes.io/warn"    = "restricted"
    }
  }
}
