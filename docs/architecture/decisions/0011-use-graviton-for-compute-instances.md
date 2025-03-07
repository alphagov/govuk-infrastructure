# 11. Use AWS Graviton (ARM) for Compute Instances

Date: 2025-03-03

## Status

Accepted

## Context

We want to switch our compute instances over to AWS Graviton-powered instance types.

The majority of our Engineers on GOV.UK (and the wider GDS) are now using GDS-issued MacBooks that are powered by "Apple Silicon" CPUs (M1/M2/M3 Pro, etc.) that is based on the ARM CPU architecture. Switching our Production (and non-Production) workloads to use the same architecture would ensure that what we develop and test on locally and in "non-Prod" matches what we run in Production.

AWS Graviton-powered Compute instances (usually denoted with a "g", e.g. M7g, R7g, etc.) are typically cheaper than their AMD (M7a, R7a) or Intel (M7i, R7i) counterparts. This will reduce running costs. ARM-based CPUs typically consume less power and have a more efficient TDP versus AMD and Intel equivalents and are potentially better for carbon footprint.

Switching to Kubernetes (EKS) has made it easy for us to easily support multiple or different CPU architectures side-by-side and to migrate our workloads gracefully with no downtime.

If we need to run x86 workloads again in the future, we can easily support this side-by-side alongside Graviton workloads, thanks to EKS/Kubernetes being architecture-agnostic.

## Decision

Update our CI/CD to Build all GOV.UK App Images with ARM support, update our EKS Node Groups to add Graviton EC2 Instances to our Clusters, then instruct Kubernetes to deploy only ARM-architecture Images and scale our x86 (Intel) Node Groups down to zero.

## Consequences

We will adopt an "ARM-first" approach for our software development and unify our architectures in Development, non-Production and Production environments. We will retain the flexibility to continue to support x86 workloads should the need arise in the future.

## Summary

Following the decision to switch all of GOV.UK over to Graviton/ARM, GOV.UK will:

* Use the same CPU architecture across Development and Production environments
* Save on compute costs and be more efficient to run
* Be flexible, as we retain the capability to run traditional x86 workloads