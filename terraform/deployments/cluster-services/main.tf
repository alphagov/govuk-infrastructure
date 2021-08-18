# The cluster-services module is responsible for Kubernetes objects within the
# EKS cluster.
#
# Any AWS resources relating to the cluster belong in
# ../cluster-infrastructure, not in this module.
#
# See https://github.com/alphagov/govuk-infrastructure/blob/main/docs/architecture/decisions/0003-split-terraform-state-into-separate-aws-cluster-and-kubernetes-resource-phases.md

terraform {
  backend "s3" {}
}
