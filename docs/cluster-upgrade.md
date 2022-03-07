# Upgrading the cluster

This is a generic guide on how to upgrade the cluster to a newer version.
As this cannot anticipate future changes, this should not be followed blindly and should be modified in accordance with the specific instructions that could arise for a particular version. Please consult AWS documentation and changelogs before using this procedure.

## General outline and things to know

To use this guide you should know ['how to apply terraform.'](../terraform/docs/applying-terraform.md)
We upgrade the cluster in place, starting with integration, followed by staging, and finally production. Integration and staging allow us to make sure that the upgrade goes without problems.
You can only upgrade from one version to the next, 1.17 to 1.18 for example but not 1.17 to 1.21.
Once an upgrade is done you cannot downgrade a cluster anymore, you will have to rebuild it from scratch if you want to downgrade.

## Step by step procedure

1. Make sure the control plane version is the same as the nodegroup, it should already be the case. If not applying the cluster-infrastructure terraform project should solve this.
1. Increment cluster_version to the version you are upgrading to in terraform/deployment/variables/<ENV>/common.tfvars 
1. Plan and apply the cluster-infrastructure terraform project, it should take about half an hour for the control plane, and another half hour for the nodegroup.
1. During the upgrade monitor the health of the running apps to make sure there is no interruption of service.
1. If aplicable you might want to upgrade the cluster add-ons next. Modify cluster_addon_versions accordingly.
1. Plan and apply the cluster-infrastructure terraform project as before. 
