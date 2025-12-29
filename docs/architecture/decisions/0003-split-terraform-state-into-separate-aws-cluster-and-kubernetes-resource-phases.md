# 3. Split Terraform state into separate AWS cluster and Kubernetes resource phases

Date: 2021-08-11

## Status

Accepted

## Context

Our Terraform will require the use of at least the `aws` and `kubernetes` providers. Elastic Kubernetes Service (EKS) 
infrastructure resources will get defined with the `aws` provider, and in-cluster resources and configuration will get 
defined with the `kubernetes` provider. The `kubernetes` provider requires arguments that are dependent on AWS resource 
outputs, so a naïve implementation would look like this:

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

Terraform providers are not handled as nodes in the Terraform plan graph, so Terraform cannot guarantee that AWS resources 
are fully created at the point that it configures the `kubernetes` provider. This will lead to non-deterministic 
behaviour and race conditions, where the values needed by the `kubernetes` provider are not available at the time it gets
initialised. Because of this, [Terraform providers should only use config values they know ahead of time](https://www.terraform.io/docs/language/providers/configuration.html#provider-configuration-1).

## Decision

Split Terraform resources into two separate states and phases:

1. `cluster-infrastructure` - EKS cluster and associated AWS resources. We do not define a `kubernetes` provider in this root.
2. `cluster-services` - Kubernetes resources (for example, ingress controllers) and in-cluster configuration (for example, 
   `aws-auth` `ConfigMaps`), with a `kubernetes` provider configured using values from a Terraform remote state resource. 
   It will be applied after `cluster-infrastructure`. We will not define an `aws` provider in this root, unless we identify
   a need to access AWS data sources for use in Kubernetes resources (for example, getting the current AWS region).

These names are placeholders, and we will select permanent ones outside of this ADR.

## Consequences

We must set the [EKS module's `manage_aws_auth` input variable](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) 
to `false` to prevent the module attempting to create `ConfigMap` objects for AWS authentication.

This should also prevent failures when tearing down EKS clusters with deployed workloads. Ingress controllers and Kubernetes 
`Service` objects commonly provision AWS load balancers that Terraform does not know about, and therefore cannot include 
in a destruction plan. It is not possible to delete an EKS cluster to which other AWS resources still point.

This decision also introduces a clear boundary and separation of concerns between Kubernetes cluster provisioning, and 
in-cluster resources and configuration. This is an important and useful separation to enforce, as it keeps the largely 
generic cluster infrastructure separate from the GOV.UK-specific configuration and supporting services. This, in principle,
provides a path to switching from an EKS cluster to any other Kubernetes cluster in any environment. It also provides 
a baseline EKS cluster that we could use for other non-GOV.UK purposes in the future.