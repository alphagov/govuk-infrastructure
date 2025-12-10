removed {
  from = kubernetes_cluster_role_binding.cluster_admins

  lifecycle {
    destroy = false
  }
}

import {
  to = kubernetes_cluster_role_binding_v1.cluster_admins
  id = "cluster-admins"
}


removed {
  from = kubernetes_cluster_role.developer

  lifecycle {
    destroy = false
  }
}

import {
  to = kubernetes_cluster_role_v1.developer
  id = "developer"
}

removed {
  from = kubernetes_cluster_role_binding.developer

  lifecycle {
    destroy = false
  }
}

import {
  to = kubernetes_cluster_role_binding_v1.developer
  id = "developer-cluster-binding"
}

removed {
  from = kubernetes_role.licensing

  lifecycle {
    destroy = false
  }
}

import {
  to = kubernetes_role_v1.licensing
  id = "licensify/licensing"
}

removed {
  from = kubernetes_role_binding.licensing

  lifecycle {
    destroy = false
  }
}

import {
  to = kubernetes_role_binding_v1.licensing
  id = "licensify/licensing-binding"
}

removed {
  from = kubernetes_cluster_role.readonly

  lifecycle {
    destroy = false
  }
}

import {
  to = kubernetes_cluster_role_v1.readonly
  id = "readonly"
}

removed {
  from = kubernetes_cluster_role_binding.readonly

  lifecycle {
    destroy = false
  }
}

import {
  to = kubernetes_cluster_role_binding_v1.readonly
  id = "readonly-cluster-binding"
}


removed {
  from = kubernetes_cluster_role.ithctester

  lifecycle {
    destroy = false
  }
}

import {
  to = kubernetes_cluster_role_v1.ithctester
  id = "ithctester"
}

removed {
  from = kubernetes_cluster_role_binding.ithctester

  lifecycle {
    destroy = false
  }
}

import {
  to = kubernetes_cluster_role_binding_v1.ithctester
  id = "ithctester-cluster-binding"
}

