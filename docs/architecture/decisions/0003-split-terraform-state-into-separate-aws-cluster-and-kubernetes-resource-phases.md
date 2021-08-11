# 3. Split terraform state into separate AWS cluster and Kubernetes resource phases

Date: 2021-08-11

## Status

Accepted

## Context

Our Terraform will require the use of at least the `aws` and `kubernetes` providers, with EKS infrastructure resources defined via `aws` and in-cluster resources and configuration defined via `kubernetes`. As the `kubernetes` provider requires arguments that are determined from AWS resource outputs, a naïve implementation would look something like this:

```
provider "aws" {
  region = var.region
}

resource "aws_eks_cluster" "cluster" {
    ...
}

provider "kubernetes" {
  host                   = aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = aws_eks_cluster.cluster.token
}
```

As Terraform providers are not fully handled as nodes in the TF plan graph it cannot be guaranteed that AWS resources will be fully created at the point that Terraform configures the `kubernetes` provider, which will lead to non-deterministic behaviour, race conditions, etc. Because of this, [Terraform providers should only use config values that are known ahead of time](https://www.terraform.io/docs/language/providers/configuration.html#provider-configuration-1).

## Decision

Split Terraform resources into two separate states and phases (actual names TBD):

1. cluster-infrastructure - EKS cluster and associated AWS resources. No `kubernetes` provider should be defined.
2. cluster-services - Kubernetes resources (e.g. ingress controllers) and in-cluster configuration (e.g. `aws-auth` ConfigMap), with the `kubernetes` provider configured via TF remote state, after `cluster-infrastructure` has been applied. No `aws` provider should be defined, unless we identify a need to access AWS data sources for use in k8s resources (e.g. obtaining current AWS region).

## Consequences

The EKS module's `manage_aws_auth` input variable must be set to `false` to prevent the module attempting to create aws auth `ConfigMap` objects.

This should also prevent potential issues when tearing down an EKS cluster with deployed workloads. As ingress controllers and k8s `Service` objects commonly provision AWS load balancers themselves, Terraform does not know about these LBs and therefore does not include them in the plan graph, which can lead to Terraform attempting to delete a cluster with references to detatched AWS resources.

This decision also introduces a clear boundary and separation of concerns between k8s cluster provisioning and in-cluster resources and configuration. This is an important and useful divison to enforce, as it keeps the largely generic cluster infrastructure separate from the GOV.UK-specific configuration and supporting services. This in principle provides a path to switching from an EKS cluster to any other Kubernetes cluster in any environment, as well as providing a baseline EKS cluster that could in future be used for other non-GOV.UK purposes.


