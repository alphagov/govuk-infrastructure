resource "kubernetes_namespace_v1" "apps" {
  metadata {
    name = var.apps_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "Terraform"
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
    labels = {
      "app.kubernetes.io/managed-by" = "Terraform"
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
    labels = {
      "app.kubernetes.io/managed-by"       = "Terraform"
      "pod-security.kubernetes.io/audit"   = "restricted"
      "pod-security.kubernetes.io/enforce" = "restricted"
      "pod-security.kubernetes.io/warn"    = "restricted"
    }
  }
}

resource "kubernetes_namespace_v1" "job-request-operator" {
  metadata {
    name = var.job_request_operator_namespace
    labels = {
      "app.kubernetes.io/managed-by"       = "Terraform"
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
    labels = {
      "app.kubernetes.io/managed-by"       = "Terraform"
      "pod-security.kubernetes.io/audit"   = "restricted"
      "pod-security.kubernetes.io/enforce" = "restricted"
      "pod-security.kubernetes.io/warn"    = "restricted"
    }
  }
}
