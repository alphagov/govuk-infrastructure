# cluster_autoscaler.tf manages the in-cluster components of the cluster
# autoscaler.
# The implementation follows the AWS docs:
# https://github.com/terraform-aws-modules/terraform-aws-eks/blob/e3216e3cf80cb59089ba0e0365c6650520000aaf/docs/autoscaling.md
#
# The AWS IAM resources for the autoscaler are in
# ../cluster-infrastructure/cluster_autoscaler_iam.tf.
# and should be updated if a new version of the cluster autoscaler requires a
# different set of permissions
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.25.0" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace  = "kube-system"
  values = [yamlencode({
    awsRegion = data.aws_region.current.name
    rbac = {
      create = true
      serviceAccount = {
        name = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_autoscaler_service_account_name
        annotations = {
          "eks.amazonaws.com/role-arn" = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_autoscaler_role_arn
        }
      }
    }
    autoDiscovery = {
      clusterName = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_id
      enabled     = true
    }
    extraArgs = {
      balance-similar-node-groups = true
    }
    replicaCount = var.desired_ha_replicas
  })]
}
