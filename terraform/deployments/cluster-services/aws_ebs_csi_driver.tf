# Patch the obsolete gp2 StorageClass which EKS creates, so that we can set our
# own one as the default.
resource "kubernetes_annotations" "rm_default_storageclass" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  force       = "true"
  metadata { name = "gp2" }
  annotations = { "storageclass.kubernetes.io/is-default-class" = "false" }
}

resource "helm_release" "ebs_csi_driver" {
  chart      = "aws-ebs-csi-driver"
  name       = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  version    = "2.17.2" # TODO: Dependabot or equivalent so this doesn't get neglected.

  values = [yamlencode({
    enableVolumeResizing = true
    controller = {
      serviceAccount = {
        create = true
        name   = data.terraform_remote_state.cluster_infrastructure.outputs.aws_ebs_csi_driver_controller_service_account_name
        annotations = {
          "eks.amazonaws.com/role-arn" = data.terraform_remote_state.cluster_infrastructure.outputs.aws_ebs_csi_driver_iam_role_arn
        }
      }
    }
    storageClasses = [{
      apiVersion = "storage.k8s.io/v1"
      kind       = "StorageClass"
      metadata = {
        name        = "ebs-gp3"
        annotations = { "storageclass.kubernetes.io/is-default-class" = "true" }
      }
      provisioner       = "ebs.csi.aws.com"
      parameters        = { type = "gp3" }
      reclaimPolicy     = "Retain"
      volumeBindingMode = "WaitForFirstConsumer"
      allowVolumeExpansion = true
    }]
  })]
}
