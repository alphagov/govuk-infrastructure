import {
  to = kubernetes_namespace_v1.apps
  id = "apps"
}

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

import {
  to = kubernetes_namespace_v1.licensify
  id = "licensify"
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

import {
  to = kubernetes_namespace_v1.datagovuk
  id = "datagovuk"
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
