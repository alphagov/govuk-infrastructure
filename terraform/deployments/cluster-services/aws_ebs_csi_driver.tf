resource "helm_release" "csi_driver" {
  chart      = "aws-ebs-csi-driver"
  name       = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  version    = "2.6.8" # TODO: Dependabot or equivalent so this doesn't get neglected.

  set {
    name  = "controller.serviceAccount.create"
    value = true
  }
  set {
    name  = "controller.serviceAccount.name"
    value = data.terraform_remote_state.cluster_infrastructure.outputs.aws_ebs_csi_driver_controller_service_account_name
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = data.terraform_remote_state.cluster_infrastructure.outputs.aws_ebs_csi_driver_iam_role_arn
  }
  set {
    name  = "enableVolumeResizing"
    value = true
  }
  values = [yamlencode({
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
