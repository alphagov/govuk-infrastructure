<!-- vale RedHat.Headings = NO -->

# 5. Use AWS Elastic Kubernetes Service (EKS) managed node groups

<!-- Heading contains proper nouns, so sentence casing is not appropriate -->
<!-- vale RedHat.Headings = YES -->

Date: 2021-08-13

## Status

Accepted

## Context

EKS supports three different types of EKS worker node groups: [managed, self-managed, and Fargate](https://docs.aws.amazon.com/eks/latest/userguide/eks-compute.html). 
The three options are not mutually exclusive. A single EKS cluster can schedule pods onto any combination of the three,
with support for many managed and self-managed node groups in a single cluster.

Managed and self-managed node groups are both implemented as EC2 instances within autoscaling groups, with all the
configuration options that this implies: security groups, custom AMIs, instance types, and so on. Fargate is a managed
service, so there are fewer configuration options available, and less management overhead.

A major consideration is the implications for [cluster upgrades](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html). 
Kubernetes has a 4-month release cycle, so upgrades will be relatively frequent. We will require a robust and mature node upgrade 
process, given the potentially destructive nature of worker updates.

At this stage our requirements for worker nodes are not fully known, so maintaining flexibility is important.

The functional capabilities of nodes in managed and self-managed node groups are equivalent, whereas Fargate places some
limitations on pod and cluster capabilities. For example, it cannot run `DaemonSets`, specify an alternative Container 
Network Interface provider, or attach persistent Elastic Block Store (EBS) volumes to pods.

The main distinction between managed and self-managed node groups is the node upgrade
process. [Managed node groups handle graceful upgrades largely automatically](https://docs.aws.amazon.com/eks/latest/userguide/update-managed-node-group.html),
whereas self-managed groups would require us to [orchestrate the update process ourselves](https://docs.aws.amazon.com/eks/latest/userguide/migrate-stack.html).

## Decision

Use [managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html).

## Consequences

We retain maximum flexibility over node configuration without having to handle the low-level details and complexity of
rolling out node updates in a running cluster.

Choosing managed node groups does not rule out the use of self-managed node groups, Fargate, or a mix of all three, in
the future. If we discover that either alternative better fits our needs, introducing self-managed or Fargate node-group
would be a purely additive process. We would not have to discard any significant work on managed node groups.
