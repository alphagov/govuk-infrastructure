locals {
  default_cluster_addons = {
    coredns            = { addon_version = "v1.14.3-eksbuild.3", resolve_conflicts_on_create = "OVERWRITE" }
    kube-proxy         = { addon_version = "v1.35.3-eksbuild.13", resolve_conflicts_on_create = "OVERWRITE" }
    kube-state-metrics = { addon_version = "v2.19.1-eksbuild.1", resolve_conflicts_on_create = "OVERWRITE" }
    metrics-server     = { addon_version = "v0.8.1-eksbuild.11", resolve_conflicts_on_create = "OVERWRITE" }
    vpc-cni = {
      addon_version               = "v1.22.2-eksbuild.1",
      resolve_conflicts_on_create = "OVERWRITE",
      before_compute              = true
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
      })
    }
    eks_pod_identity_addon = {
      addon_version = "v1.3.10-eksbuild.2", resolve_conflicts_on_create = "OVERWRITE"
    }
  }
}

resource "aws_eks_addon" "after_node_groups" {
  for_each = { for k, v in local.default_cluster_addons : k => v if try(!v.before_compute, true) }

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.key
  addon_version               = each.value.addon_version #e.g., previous version v1.9.3-eksbuild.3 and the new version is v1.10.1-eksbuild.1
  configuration_values        = try(each.value.configuration_values, null)
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_create

  depends_on = [
    aws_eks_node_group.workers
  ]
}

resource "aws_eks_addon" "before_node_groups" {
  for_each = { for k, v in local.default_cluster_addons : k => v if try(v.before_compute, false) }

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.key
  addon_version               = each.value.addon_version #e.g., previous version v1.9.3-eksbuild.3 and the new version is v1.10.1-eksbuild.1
  configuration_values        = try(each.value.configuration_values, null)
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_create

}
