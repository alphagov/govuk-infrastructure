resource "helm_release" "aws_ebs_csi_driver" {
  name             = "aws-ebs-csi-driver"
  repository       = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart            = "aws-ebs-csi-driver"
  version          = "2.39.3"
  namespace        = "kube-system"
  create_namespace = true
  timeout          = var.helm_timeout_seconds
  values = [yamlencode({
    enableVolumeResizing = true
    controller = {
      serviceAccount = {
        create = true
        name   = "ebs-csi-controller-sa"
        annotations = {
          "eks.amazonaws.com/role-arn" = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.aws_ebs_csi_driver_iam_role_arn
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
        reclaimPolicy        = "Retain"
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
