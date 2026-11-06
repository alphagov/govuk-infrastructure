resource "helm_release" "aws_ebs_csi_driver" {
  name             = "aws-ebs-csi-driver"
  repository       = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart            = "aws-ebs-csi-driver"
  version          = "2.67.2"
  namespace        = "aws-ebs-csi-driver"
  create_namespace = true
  timeout          = 1200
  values = [yamlencode({
    controller = {
      enableMetrics = true
      serviceAccount = {
        create = true
        name   = "ebs-csi-controller-sa"
        annotations = {
          "eks.amazonaws.com/role-arn" = module.aws_ebs_csi_driver_iam_role.arn
        }
      }
    }
    storageClasses = [
      {
        apiVersion = "storage.k8s.io/v1"
        kind       = "StorageClass"
        metadata = {
          name = "ebs-gp3"
          annotations = {
            "storageclass.kubernetes.io/is-default-class" = "true"
          }
        }
        provisioner = "ebs.csi.aws.com"
        parameters = {
          type = "gp3"
        }
        reclaimPolicy        = "Delete"
        volumeBindingMode    = "WaitForFirstConsumer"
        allowVolumeExpansion = true
      }
    ]
  })]
}

# Patch the obsolete gp2 StorageClass which EKS creates, so that we can set our
# own one as the default.
resource "kubernetes_annotations" "rm_default_storageclass" {
  depends_on  = [helm_release.aws_ebs_csi_driver]
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  force       = "true"
  metadata { name = "gp2" }
  annotations = { "storageclass.kubernetes.io/is-default-class" = "false" }
}
