<!-- vale RedHat.Headings = NO -->
# 26. Adopt Cilium
<!-- vale RedHat.Headings = YES -->

Date: 2026-11-03

## Status

Accepted

## Context

Our cluster uses the AWS VPC CNI whose default policy is to allow all traffic between all pods, which results in a flat
network with no segregation. We have not implemented additional network policies, so we have inherited the default 
policy.

Our goal is to introduce a level of network segmentation and prevent applications A and B from communicating if they
don't have a need to. We want to do the same with backing services.

<!-- vale GOVUK.Spelling = NO -->
<!-- vale Vale.Terms = NO -->
<!-- Paragraphs contain product names which trigger the rules in a false positive way -->
We started by looking at what tools exist in the Kubernetes ecosystem for generating a service map that we could use to 
inform the network policies we need to write. We found a small number of tools such as
[AWS CloudWatch Network Flow Monitor](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-NetworkFlowMonitor.html)
and [Inspektor Gadget](https://inspektor-gadget.io/). The former is an AWS feature which offers visibility into what is
happening in your network, and crucially for us it is able to generate a map of it. We chose to adopt it because its 
features are useful, but unfortunately the service map isn't a complete one; it's limited to drawing a map based on ~500
data flows.

The latter promised to inspect the traffic flowing through our nodes with an eBPF module, and to produce a set of 
Kubernetes network policies to allow the traffic it saw. We didn't pick it because it produced an overwhelming volume
of data which we'd have had to put effort into distilling. The effort was not worth it because we already had a service
map produced by the CloudWatch Network Flow Monitor.
<!-- vale GOVUK.Spelling = YES -->
<!-- vale Vale.Terms = YES -->

The other half of the problem was controlling egress from pods to backing services. Kubernetes standard network policies
operate at layers 3 and 4 (TCP/IP; ports and addresses), but our backing services don't have fixed IP addresses. They 
rely on connecting with a host name and use DNS to failover as necessary.

We were aware that Kubernetes network policies, as implemented by the AWS VPC CNI, had no layer 7 capability, thus 
ruling them out as a solution. Instead, we looked to the Kubernetes ecosystem.

As a team we had our eye on Cilium for some time because we know it has a number of features that could be beneficial
to us in general. Historically we'd hedged against adopting it because it seemed to be overkill for the problems we
were facing in those moments. We decided now would be a good time to evaluate its layer 7 DNS-based network policies, and
contrast it with two other options:

1. DNS-based policies in EKS Auto Mode
2. EKS security group policy

We ultimately decided against adopting EKS Auto Mode (see [ADR 25](./0025-do-not-adopt-eks-auto-mode.md)), and we found
that managing security groups for EKS security group policies would be too manual and error-prone for our tastes.

We were happy with Cilium's DNS-based policies, but concerned with the potential disruption and outage in deploying it.
We deployed fresh ephemeral clusters, and trialed deploying and rolling it back. It all went smoothly and our fears
were allayed. 

## Decision

1. Adopt Cilium and deploy it in [chaining mode](https://docs.cilium.io/en/stable/installation/cni-chaining-aws-cni/) with
the existing VPC CNI plugin.

2. Deploy [Hubble](https://docs.cilium.io/en/stable/observability/hubble/), Cilium's network
observability tool, because we have historically had little insight into such things. We also predict it will be useful
in meeting security requirements down the line.

3. Use Cilium network policy's `toFDQN` feature to restrict outbound traffic to backing services, using the DNS name of
the service.

## Consequences

Choosing to use Cilium is a big commitment and a big change because it alters 
[how networking is implemented](https://cilium.io/blog/2026/04/25/understanding-kubernetes-networking/)
and how network policies are enforced. It also gives us another 
[non-trivial upgrade process](https://docs.cilium.io/en/stable/operations/upgrade/) for a core system component.

These changes have three additional technical consequences:

* The [CiliumEndpoint](https://docs.cilium.io/en/latest/security/policy/lifecycle/) that provides an internal IP for
each pod becomes a new point of failure for networking (including DNS), and increases the per-pod CPU and memory load on
a node
* Hubble is a new source of logs, with the potential to be a big volume. Storing them will cost us, and we will need to
decide what the correct retention period is.
* Rolling back network related changes could become more complex because of the dependency on a Custom Resource 
Definition.

Beyond the technical, we will need to scour our documentation, run books, and troubleshooting guidance for references to
Kubernetes networking and update them appropriately.

However, we believe the value it can offer us more than outweighs the potential negatives and incurred costs. The 
negatives are also somewhat negated by how common Cilium is in the Kubernetes space, meaning our networking setup isn't 
so different to a lot of other clusters.