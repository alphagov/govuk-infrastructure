resource "kubernetes_namespace_v1" "gatekeeper" {
  metadata {
    name = "gatekeeper-system"

    labels = {
      "name"                               = "gatekeeper-system"
      "admission.gatekeeper.sh/ignore"     = "no-self-managing"
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

resource "helm_release" "gatekeeper" {
  name       = "gatekeeper"
  namespace  = kubernetes_namespace_v1.gatekeeper.id
  repository = "https://open-policy-agent.github.io/gatekeeper/charts"
  chart      = "gatekeeper"
  version    = "3.23.0"

  # https://github.com/open-policy-agent/gatekeeper/blob/master/charts/gatekeeper/values.yaml
  values = [templatefile("${path.module}/templates/values.yaml.tpl", {
    audit_from_cache                     = "true"
    post_install_label_namespace         = "false"
    constraint_violations_max_to_display = var.constraint_violations_max_to_display
    controller_mem_limit                 = var.controller_mem_limit
    controller_mem_req                   = var.controller_mem_req
    audit_mem_limit                      = var.audit_mem_limit
    audit_mem_req                        = var.audit_mem_req
  })]

  lifecycle {
    ignore_changes = [keyring]
  }
}

resource "time_sleep" "wait_30_seconds" {
  create_duration  = "30s"
  destroy_duration = "30s"

  depends_on = [helm_release.gatekeeper]
}

module "constraint_templates" {
  source     = "./constraint_templates"
  depends_on = [time_sleep.wait_30_seconds]
}

resource "time_sleep" "wait_30_seconds_for_templates" {
  create_duration  = "30s"
  destroy_duration = "30s"

  depends_on = [module.constraint_templates]
}


module "constraints" {
  source = "./constraints"

  dryrun_map = var.dryrun_map

  depends_on = [time_sleep.wait_30_seconds_for_templates]
}

/* add resources to sync here */
resource "kubectl_manifest" "config_sync" {
  depends_on = [helm_release.gatekeeper]

  yaml_body = <<YAML
apiVersion: config.gatekeeper.sh/v1alpha1
kind: Config
metadata:
  name: config
  namespace: "gatekeeper-system"
spec:
  sync:
    syncOnly:
      - group: "networking.k8s.io"
        version: "v1"
        kind: "Ingress"
      - group: ""
        version: "v1"
        kind: "Namespace"
      - group: ""
        version: "v1"
        kind: "Pod"
      - group: ""
        version: "v1"
        kind: "Service"
YAML
}

