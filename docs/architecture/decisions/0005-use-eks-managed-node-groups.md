# 5. Use EKS managed node groups

Date: 2021-08-13

## Status

Accepted

## Context

EKS supports three different types of EKS worker node groups: [managed, self-managed, and Fargate](https://docs.aws.amazon.com/eks/latest/userguide/eks-compute.html). The three options are not mutually exclusive, and a single EKS cluster can schedule pods onto any combination of the three, with support for multiple managed and self-managed node groups within a single cluster.

Managed and self-managed node groups are both implemented as EC2 instances within autoscaling groups, with all of the configuration options that this implies (security groups, custom AMIs, instance types, etc). As Fargate is a managed service there are fewer configuration options available, but also less management overhead.

A major consideration is the implications for [cluster upgrades](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html). As Kubernetes has a 4-month release cycle, upgrades will be relatively frequent, so a robust and mature node upgrade process is required, given the potentially destructive nature of worker updates.

At this stage our requirements for worker nodes are not fully known, so maintaining flexibility at this stage is important.

The functional capabilities of nodes in managed and self-managed node groups are equivalent, whereas Fargate places some limitations on pod and cluster capabilities (e.g. cannot run `DaemonSets`, specify an alternative Container Network Interface provider, or attach persistent EBS volumes to pods).

The main distinction between managed and self-managed node groups is the node upgrade process; [managed node groups handle graceful upgrades largely automatically](https://docs.aws.amazon.com/eks/latest/userguide/update-managed-node-group.html), whereas self-managed groups would require us to [orchestrate the update process ourselves](https://docs.aws.amazon.com/eks/latest/userguide/migrate-stack.html).

## Decision

Use [managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html).

## Consequences

We retain maximum flexibility over node configuration without having to handle the low-level details and complexity of rolling out node updates in a running cluster.

Choosing managed node groups does not rule out the use of self-managed node groups or Fargate (or a mix of all three) in the future if we discover that either alternative better fits our needs. Introducing self-managed node groups or Fargate would be a purely additive process, so no significant work on managed node groups would be discarded.
