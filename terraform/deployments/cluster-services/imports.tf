removed {
  from = kubernetes_namespace.datagovuk

  lifecycle {
    destroy = false
  }
}

import {
  to = kubernetes_namespace_v1.datagovuk
  id = var.datagovuk_namespace
}

removed {
  from = kubernetes_namespace.monitoring

  lifecycle {
    destroy = false
  }
}

import {
  to = kubernetes_namespace_v1.monitoring
  id = "monitoring"
}

removed {
  from = kubernetes_namespace.apps

  lifecycle {
    destroy = false
  }
}

import {
  to = kubernetes_namespace_v1.apps
  id = var.apps_namespace
}

removed {
  from = kubernetes_namespace.licensify

  lifecycle {
    destroy = false
  }
}

import {
  to = kubernetes_namespace_v1.licensify
  id = var.licensify_namespace
}

import {
  to = kubernetes_secret_v1.dex_client[each.key]
  id = "${each.value.namespace}/dex-client-${each.value.client}"

  for_each = local.dex_clients_namespaces
}
