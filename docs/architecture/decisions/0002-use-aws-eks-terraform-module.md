# 2. Use aws-eks terraform module

Date: 2021-08-10

## Status

Accepted

## Context

A fully configured EKS cluster requires many AWS resources and a lot of configuration. Defining each resource in our own Terraform module maximises flexibility but also requires a significant level of effort. We could instead make use of the [existing Terraform registry EKS module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) to optimise for speed of delivery.

## Decision

Adopt the [existing Terraform registry EKS module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest).

## Consequences

A fully configured EKS cluster can be defined quickly and easily, as many module defaults will be fine for our purposes for the foreseeable future.

The EKS module has comprehensive support for many of the options for EKS cluster config (e.g. worker node types). This will allow us to make changes more easily, and to experiment with different options quickly.

It is possible that we will in future discover some areas of the module that don't work for our needs. Potential options in that instance include contributing to the module, forking it, or moving to our own module (likely with large chunks of code taken from the EKS module).

We must be careful to avoid errors and issues that may be caused by the module's default use of a terraform `kubernetes` provider that is configured by AWS resource outputs. The behaviour of providers derived from other providers' resources is non-deterministic and can lead to intermittent and unpredictable issues - see the [warning callout in the Kubernetes provider docs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-managed-kubernetes-cluster-resources). The approach for handling this limitation will be covered in a subsequent ADR.
