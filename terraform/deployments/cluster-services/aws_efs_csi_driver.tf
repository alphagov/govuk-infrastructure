resource "helm_release" "efs_csi_driver" {
  chart      = "aws-efs-csi-driver"
  name       = "aws-efs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  version    = "3.1.5" # TODO: Dependabot or equivalent so this doesn't get neglected.

  values = [yamlencode({
    controller = {
      serviceAccount = {
        create = true
        name   = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.aws_efs_csi_driver_controller_service_account_name
        annotations = {
          "eks.amazonaws.com/role-arn" = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.aws_efs_csi_driver_iam_role_arn
        }
      }
    }
    storageClasses = [{
      name          = "efs-sc"
      apiVersion    = "storage.k8s.io/v1"
      reclaimPolicy = "Retain"
    }]
  })]
}