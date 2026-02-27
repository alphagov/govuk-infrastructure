resource "kubernetes_namespace_v1" "fluent_bit" {
  metadata {
    name = local.logging_namespace
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

resource "helm_release" "fluent_bit" {
  name       = "fluent-bit"
  chart      = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  version    = "0.56.0"
  namespace  = kubernetes_namespace_v1.fluent_bit.id

  values = [yamlencode({
    image = {
      repositoty = "cr.fluentbit.io/fluent/fluent-bit"
      pullPolicy = "IfNotPresent"
      tag        = "-"
    }

    serviceMonitor = {
      enabled       = true
      interval      = "10s"
      scrapeTimeout = "10s"
    }

    serviceAccount = {
      create = false
      name   = "${kubernetes_service_account_v1.this.metadata[0].name}"
    }

    securityContext = {
      privileged               = false
      allowPrivilegeEscalation = false
      runAsNonRoot             = true
      runAsUser                = 1000
      runAsGroup               = 1000
      fsGroup                  = 1000
      capabilities = {
        drop = ["NET_RAW"]
      }
    }

    daemonSetVolumes = [{
      name = "etcdmachineid"
      hostPath = {
        path = "/etc/machine-id"
        type = "File"
      }
      },
      {
        name = "tetragonlogs"
        hostPath = {
          path = "/var/run/cilium/tetragon/"
          type = ""
        }
      },
    ]

    daemonSetVolumeMounts = [{
      name      = "etcdmachineid"
      mountPath = "/etc/machine-id"
      readonly  = true
      },
      {
        name      = "tetragonlogs"
        mountPath = "/var/run/cilium/tetragon/"
        readonly  = true
    }]

    config = {
      service = <<-EOF
      [SERVICE]
          Log_Level info
          Health_Check On
          HTTP_Server On
      EOF
      inputs  = <<-EOF
    [INPUT]
        Name tail
        Tag tetragon_log
        Path /var/run/cilium/tetragon/tetragon.log
    EOF

      filters = <<-EOF
    EOF

      outputs = <<-EOF
    [OUTPUT]
        Name       s3
        Match      *
        Region     eu-west-1
        Bucket     ${var.govuk_environment}-eks-exec-audit-logs
        Compression gzip
        S3_Key_Format /%Y/%m/%d/%H
    EOF
    }
  })]

  depends_on = [helm_release.tetragon]
}

