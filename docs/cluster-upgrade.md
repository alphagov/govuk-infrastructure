# Upgrading the cluster

This is a generic guide on how to upgrade the cluster to a newer version.
As this cannot anticipate future changes, this should not be followed blindly and should be modified in accordance with the specific instructions that could arise for a particular version. Please consult AWS documentation and changelogs before using this procedure.

## General outline and things to know

To use this guide you should know ['how to apply terraform.'](../terraform/docs/applying-terraform.md)
We upgrade the cluster in place, starting with integration, followed by staging, and finally production. Integration and staging allow us to make sure that the upgrade goes without problems.
You can only upgrade from one version to the next, 1.17 to 1.18 for example but not 1.17 to 1.21.
Once an upgrade is done you cannot downgrade a cluster anymore, you will have to rebuild it from scratch if you want to downgrade.

## Step by step procedure

1. Make sure the control plane version is the same as the nodegroup, it should already be the case. If not, applying a new run in the  `cluster-infrastructure-<ENV>` workspace in Terraform Cloud will solve this.
2. In the AWS EKS console choose 'Update cluster version' and select the version you wish to update to
3. Upgrade the cluster add-ons. See the docs for each addon under [EKS Addons](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html) for Amazon's recommended addon versions to use for a given cluster version.
4. Upgrade the node group by selecting the 'Compute' tab in the AWS EKS console and select 'Update now'. Run `kubectl get nodes` to verify that the upgrade has completed successfully.
5. In the ArgoCD console delete the `release` app and verify that it is re-created
6. Increment cluster_version to the version you are upgrading to in terraform/tfc-configuration/variables-<ENV>.tf 
7. Plan and apply a new run in the `tfc-configuration` workspace in Terraform Cloud. This will update the variable sets to the new cluster_version 
8. Plan and apply a new run in the `cluster-infrastructure-<ENV>` workspace in Terraform Cloud.
