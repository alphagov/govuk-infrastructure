removed {
  from = kubernetes_namespace_v1.apps
  lifecycle {
    destroy = false
  }
}

removed {
  from = kubernetes_namespace_v1.licensify
  lifecycle {
    destroy = false
  }
}

removed {
  from = kubernetes_namespace_v1.datagovuk
  lifecycle {
    destroy = false
  }
}

