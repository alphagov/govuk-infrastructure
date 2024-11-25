# Patch the obsolete gp2 StorageClass which EKS creates, so that we can set our
# own one as the default.
resource "kubernetes_annotations" "rm_default_storageclass" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  force       = "true"
  metadata { name = "gp2" }
  annotations = { "storageclass.kubernetes.io/is-default-class" = "false" }
}
