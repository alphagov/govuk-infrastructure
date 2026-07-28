resource "kubectl_manifest" "constraints" {
  for_each = local.constraint_map

  yaml_body = yamlencode("${each.value}")
  wait      = true
}

