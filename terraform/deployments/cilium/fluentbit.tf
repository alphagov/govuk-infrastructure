resource "helm_release" "fluentbit" {
  name      = "fluent-bit-hubble-exporter"
  namespace = kubernetes_namespace_v1.cilium.metadata[0].name

  repository = "oci://ghcr.io/fluent/helm-charts/"
  chart      = "fluent-bit-collector"
  version    = "1.1.3"

  values = [yamlencode({
    automountServiceAccountToken = true
    storage = {
      enabled = true
    }
    config = {
      service = {
        flush     = 5
        log_level = "info"
      }
      pipeline = {
        inputs = [
          {
            name             = "tail"
            alias            = "hubble-export"
            path             = "/var/run/cilium/hubble/events.log"
            tag              = "hubble.*"
            parser           = "json"
            refresh_interval = 5
            rotate_wait      = 30
            "storage.type"   = "$${STORAGE_TYPE_PREFER_FS}"
            db               = "$${STORAGE_PATH}/hubble-export-tail.db"
          }
        ]

        outputs = [
          {
            alias = "out"
            match = "*"
            name  = "stdout"
          }
        ]
      }
    }
    hostVolumes = [
      // This first volume is included by default and we should keep it so fluent bit can augment the logs
      {
        name      = "machine-id"
        mountPath = "/etc/machine-id"
        hostPath = {
          path = "/etc/machine-id"
          type = "File"
        }
        }, {
        name      = "hubble-export"
        mountPath = "/var/run/cilium/hubble"
        hostPath = {
          path = "/var/run/cilium/hubble"
          type = "Directory"
        }
      }
    ]
  })]
}
