resource "helm_release" "efs_csi_driver" {
  chart      = "aws-efs-csi-driver"
  name       = "aws-efs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  version    = "2.2.7" # TODO: Dependabot or equivalent so this doesn't get neglected.

  values = [yamlencode({
    controller = {
      serviceAccount = {
        create = true
        name   = data.terraform_remote_state.cluster_infrastructure.outputs.aws_efs_csi_driver_controller_service_account_name
        annotations = {
          "eks.amazonaws.com/role-arn" = data.terraform_remote_state.cluster_infrastructure.outputs.aws_efs_csi_driver_iam_role_arn
        }
      }
    }
    storageClasses = [{
      name         = "clamav-db-efs-sc"
      apiVersion   = "storage.k8s.io/v1"
      mountOptions = ["tls"]
      parameters = {
        provisioningMode = "efs-ap"
        fileSystemId     = data.terraform_remote_state.cluster_infrastructure.outputs.clamav_db_efs_id
        directoryPerms   = "755"
      }
      reclaimPolicy     = "Retain"
      volumeBindingMode = "WaitForFirstConsumer"
    }]
  })]
}
