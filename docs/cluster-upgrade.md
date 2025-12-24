# Upgrading the cluster

This is a generic guide on how to upgrade the cluster to a newer version.
As this cannot predict future changes, you should not follow it blindly. You should makes changes to it in accordance with the 
specific instructions that arise for a particular version. Please consult AWS documentation and changelogs before using 
this procedure.

## General outline and things to know

To use this guide you should know ['how to apply terraform.'](../terraform/docs/applying-terraform.md)
We upgrade the cluster in place, starting with integration, followed by staging, and finally production. Integration and staging allow us to make sure that the upgrade goes without problems.

You can only upgrade from one version to the next, 1.17 to 1.18 for example but not 1.17 to 1.21.

Once you have completed a cluster upgrade, you cannot roll it back. You will have to rebuild it from scratch if you need to do so.

## Preparing to upgrade

As a pre-requisite for upgrading the cluster, there are two things you should do: 

1. Check the Elastic Kubernetes Service (EKS) [upgrade insights](https://docs.aws.amazon.com/eks/latest/userguide/cluster-insights.html) for each cluster
2. Read the release notes for the version you're about to upgrade to and note on the story any changes that might affect us. Consider using this template to keep things simple:
```markdown
# Kubernetes VERSION notable changes

Information pulled from LINK TO RELEASE NOTES

❌  Doesn't affect us
❓  Might affect us
✅  Affects us but doesn't need action
⚠️  Affects us and needs action

## Deprecations and removals
❌  Deprecation/removal that doesn't affect us
⚠️  Deprecation/removal that means we need to do some work before or after the upgrade
❓  Deprecation/removal that we need to look into after the upgrade

## Graduations
❓ Graduation that might be good for us in the future
⚠️ Graduation that enables something for us in the immediate term, or that changes something and requires us to change with it
❌ Graduation that has no bearing on us at all 


## Summary
A one sentence summary of the changes and how/if they affect us
```

If any of these steps point to an issue that would prevent you upgrading, you should stop here. 

If any of these steps point to a change that needs making before the upgrade, raise it with the team and decide how
to proceed.


## Step-by-step procedure
You can upgrade the EKS cluster by changing the version in Terraform and applying the change through Terraform Cloud. Terraform
will first upgrade the control plane version, then the node groups, and finally any cluster add-ons. It will pick the most appropriate
version for each <!-- vale RedHat.SimpleWords=OFF -->component<!-- vale RedHat.SimpleWords=ON -->.

1. Increment `cluster_version` to the version you are upgrading to in `terraform/tfc-configuration/variables-<ENV>.tf`
2. Raise the change as a PR, and merge it 
3. Plan and apply a new run in the `tfc-configuration` workspace in Terraform Cloud. This will update the variable sets to the new `cluster_version`
4. Plan and apply a new run in the `cluster-infrastructure-<ENV>` workspace in Terraform Cloud.

You should expect it to take 30-45 minutes to upgrade each cluster.