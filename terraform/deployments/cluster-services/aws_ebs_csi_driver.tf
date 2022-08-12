resource "helm_release" "csi_driver" {
  chart      = "aws-ebs-csi-driver"
  name       = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  version    = "2.9.0" # TODO: Dependabot or equivalent so this doesn't get neglected.

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
      apiVersion        = "storage.k8s.io/v1"
      kind              = "StorageClass"
      metadata          = { name = "ebs-sc" }
      provisioner       = "ebs.csi.aws.com"
      parameters        = { type = "gp3" }
      reclaimPolicy     = "Retain"
      volumeBindingMode = "WaitForFirstConsumer"
    }]
  })]
}
