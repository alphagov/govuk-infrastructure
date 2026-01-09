<!-- vale RedHat.Headings = NO -->
# 11. Use AWS Graviton (ARM) for compute instances
<!-- Heading contains proper nouns -->
<!-- vale RedHat.Headings = YES -->

Date: 2025-03-03

## Status

Accepted

## Context

We want to switch our compute instances over to AWS Graviton-powered instance types.

<!-- vale RedHat.PassiveVoice = NO -->
The majority of engineers on GOV.UK (and the wider GDS) are using GDS-issued MacBooks, which have Apple Silicon CPUs that 
are based on the ARM CPU architecture. Switching our Production (and non-Production) workloads to use the same
architecture would ensure that what we develop and test on locally and in non-Prod matches what we run in Production.
<!-- "are based on" is a valid sure of passive voice -->
<!-- vale RedHat.PassiveVoice = YES -->

AWS Graviton-powered compute instances (usually denoted with a "g", e.g. `M7g`, `R7g`, and so on) are typically cheaper 
than their AMD (`M7a`, `R7a`) or Intel (`M7i`, `R7i`) counterparts. This will reduce running costs. ARM-based CPUs typically
consume less power and have a more efficient total power draw versus AMD and Intel equivalents, and are potentially better
for our carbon footprint.

Switching to AWS Elastic Kubernetes Service (EKS) has made it easier for us to support different CPU architectures
side-by-side and to migrate our workloads gracefully with no downtime.

If we need to run x86_64 workloads again in the future, we can easily support this side-by-side with Graviton
workloads, thanks to Kubernetes being architecture-agnostic.

## Decision

1. Update our CI/CD to build all GOV.UK app images with ARM support
2. Update our EKS node groups to add Graviton EC2 instances to our clusters
3. Instruct Kubernetes to deploy only ARM-architecture images
4. Scale our x86_64 (Intel) node groups down to zero.

## Consequences

We will adopt an ARM-first approach for our software development and unify our architectures in Development,
non-Production and Production environments. We will retain the flexibility to continue to support x86_64 workloads should
the need arise in the future.

### Cost Savings

The cost saving per-instance is about 15% when stepping from `m6i` to `m7g` instances of the same "size". However,
the benefits are potentially more significant when combined with more efficient compute, right-sizing efforts
and committing to the correct AWS savings plans.

Further, making improvements to our workload resource requests and limits has allowed us to right-size our
infrastructure and not need to over-provision our compute instances. This has resulted in a 55% cost saving when combined
with our switch to Graviton hardware. Savings Plans will improve our savings further.

The GOV.UK Platform Engineering team can produce calculations on-request.

## Summary

Following the decision to switch all of GOV.UK over to Graviton, GOV.UK will:

* Use the same CPU architecture across Development and Production environments
* Save on compute costs and be more efficient to run
* Be flexible, because we retain the capability to run traditional x86 workloads