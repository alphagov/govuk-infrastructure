<!-- vale RedHat.Headings = NO -->
# 25. Do not adopt AWS EKS Auto Mode
<!-- vale RedHat.Headings = YES -->

Date: 2025-10-29

## Status

Accepted

## Context

[AWS EKS Auto Mode](https://aws.amazon.com/eks/auto-mode/) is an additional offering from the AWS EKS service that 
automates the lifecycle management of Kubernetes clusters. In its own words:

> It simplifies Kubernetes management by automatically provisioning infrastructure, selecting optimal compute instances,
> dynamically scaling resources, continuously optimizing costs, managing core add-ons, patching operating systems, and 
> integrating with AWS security services

It also offers [DNS network policies](https://docs.aws.amazon.com/eks/latest/userguide/auto-net-pol.html), which is the 
feature we began investigating it for.

Our need at the time was to be able to create network policies for traffic leaving the cluster, specifically for 
application backing services such as databases and caches. We required DNS enforcement for that purpose because the 
backing services mostly have IP addresses in the CIDR block, but addresses within that block are unpredictable. Using a 
policy based on the CIDR block alone would not meet the need.

## Decision

Do not adopt AWS EKS Auto Mode.

<!-- vale RedHat.PassiveVoice = NO -->
<!-- "are collected" is valid passive voice here -->
We reached this conclusion having evaluated the DNS network policies. The network policies are good and work as we would
want them to, but AWS EKS Auto Mode has a single big showstopper for us: it expects that logs are collected from the 
workloads. 
<!-- vale RedHat.PassiveVoice = YES -->

This would be a big change to how we collect logs today. We currently use a single log aggregator per node to send logs 
to an external system. To adapt to collecting logs from workloads would mean adding and configuring sidecar containers
to every application we deploy, and finding ways to deploy sidecars in every third-party Helm chart we use.

We do not think that the value of DNS network policy enforcement outweighs the downsides of the logging arrangement,

We also don't experience the kinds of upgrade and maintenance pains that AWS EKS Auto Mode, with its 10% surcharge per 
node, sets out to solve. Ergo we are not the target market for the feature.

## Consequences

1. We will not adopt AWS EKS Auto Mode
2. We have this ADR to explain why have not adopted it at this point in time