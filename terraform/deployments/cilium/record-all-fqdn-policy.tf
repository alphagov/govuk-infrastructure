resource "kubectl_manifest" "record-all-fqdns" {
  yaml_body = file("${path.module}/record-all-fqdn-policy.yaml")

  server_side_apply = true

  depends_on = [
    helm_release.cilium,
  ]
}
