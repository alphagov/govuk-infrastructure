removed {
  from = kubernetes_role_binding.poweruser

  lifecycle {
    destroy = false
  }
}

import {
  to = kubernetes_role_binding_v1.poweruser
  id = "${var.datagovuk_namespace}/poweruser-${var.datagovuk_namespace}"
}

