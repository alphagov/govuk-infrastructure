# 8. Use external-secrets for secrets storage

Date: 2021-08-26

## Status

Accepted

## Context

We want to make use of AWS SecretsManager for secrets storage, rather than relying solely on Kubernetes secrets. We want
to do this because we want the ability to reconstitute the full state of a running cluster from an external source of truth.
In most cases the external source of truth is a Git repository, but there are significant challenges and pain points when
managing sensitive config in Git repositories. These pains are the driver for using SecretsManager.

We must maintain end-to-end encryption of secrets, up until the point a running container uses a secret, where Kubernetes
must necessarily decrypt the secret for use.

We must be able to enforce access control on secrets, following the principle of least privilege.

We must be able to support rotation of secrets in AWS SecretsManager, where a change of value in AWS is automatically
propagated to services in the cluster.

Kubernetes should expose secrets to pods as `Secret` resources, to allow the use of standard patterns and existing 
third-party Kubernetes projects (primarily Helm charts). The use of externally-managed secrets should have a minimal 
impact on development teams, and Helm chart and Kubernetes resource authors, because we will manage the SecretsManager 
integration at a cluster level.

Several projects exist for AWS SecretsManager integration with Kubernetes Secrets, the most notable being:

- [Secrets Store Container Storage Interface (CSI) Driver](https://secrets-store-csi-driver.sigs.k8s.io)
- [`external-secrets`](https://github.com/external-secrets/external-secrets)
- [`kubernetes-external-secrets`](https://github.com/external-secrets/kubernetes-external-secrets)

Secrets Store CSI is a [Kubernetes Special Interest Group (SIG)](https://github.com/kubernetes/community/blob/master/sig-list.md) 
project. It aims to implement external secrets in Kubernetes clusters by using the [Container Storage Interface](https://kubernetes.io/blog/2019/01/15/container-storage-interface-ga/),
a standard for exposing file and block interfaces to containers.

<!-- vale RedHat.PassiveVoice = NO -->
<!-- vale RedHat.SentenceLength = NO -->
`external-secrets` and `kubernetes-external-secrets` are closely-related projects that have been brought together as
part of the [external-secrets](https://github.com/external-secrets) GitHub org, which has worked to unify many projects in this space and create
a [single specification for an external secrets Custom Resource Definition](https://github.com/external-secrets/crd-spec/blob/main/Spec.md).
<!-- Valid use of passive voice in this long sentence -->
<!-- vale RedHat.SentenceLength = YES -->
<!-- vale RedHat.PassiveVoice = YES -->

`external-secrets` is the successor project to `kubernetes-external-secrets`, which rewrites
the [Kubernetes Operator](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/) in Go rather than JavaScript, 
and adopts the standardised Custom Resource Definition (CRD). It also changes the resource object model to separate 
using secrets in the application, and the specific access and authentication and authorization implementation for a given external secret backend.
Both projects support AWS SecretsManager, HashiCorp Vault, and Google Cloud Platform and Azure equivalents. The project maintainers view
`kubernetes-external-secrets` as on a deprecation path, and `external-secrets` is currently classed as alpha:

> [Kubernetes External Secrets]: a very popular solution that came from within Godaddy and was written in JS and
> supports a lot of providers (but will be deprecated)
>
> [External Secrets]: New solution written in golang, aspires to support all the same providers, but we are still
> working on getting most of the providers stable and out of alpha. Eventually, the idea is to substitute KES. Anyways the
> migration is pretty much like @Flydiverny said since retro-compatibility with original solutions was not something that
> we aimed for. Completely new CRD and all that.

(from [Kubernetes Slack](https://kubernetes.slack.com/archives/C017BF84G2Y/p1626186324108900?thread_ts=1626104012.105800&cid=C017BF84G2Y))

We have created proofs of concept for all three options:

1. **Secrets Store CSI** - works, but relatively complex to get up and running. Secrets rotation and syncing with
   Kubernetes `Secrets` currently experimental/alpha. The use of CSI volumes as an
   abstraction [requires that secrets get mounted as a volume](https://secrets-store-csi-driver.sigs.k8s.io/topics/sync-as-kubernetes-secret.html)
   on disk even when secrets are only consumed as environment variables by containers. Secrets volume definition in `Pods` and 
   `Deployments` is quite verbose and something of a leaky abstraction, because it must specify the CSI driver and volume attributes.
   Overall CSI feels like the wrong abstraction for external secret stores, because they are fundamentally neither file nor
   block storage.
2. **`kubernetes-external-secrets`** - Quick and easy to get up and running and simple to use within an application it 
   requires only one resource: `ExternalSecret`. Works as expected with [IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html).
   In-cluster secrets access control is [relatively basic and coarse-grained](https://github.com/external-secrets/kubernetes-external-secrets#scoping-access).
   Does not support a highly-available deployment (replicas) without the risk of excessive API calls or race
   conditions.
3. **`external-secrets`** - More complex to get up and running than `kubernetes-external-secrets`, and less so than Secrets
   Store CSI. Documentation is somewhat thin, although [the`external-secrets` API spec](https://external-secrets.io/spec/) 
   is comprehensive. Supports [a few modes of operation for multi-tenancy](https://external-secrets.io/guides-multi-tenancy/)
   and access control. Project is still in a relatively early stage, so APIs might change. Supports highly available
   deployments via leadership election.

While multi-tenancy is not a primary concern at this stage, we might discover a need for some level of access control and
segregation as we introduce more applications.

## Decision

Use [**`external-secrets`**](https://external-secrets.io).

While `kubernetes-external-secrets` is more mature and slightly simpler to deploy and use, it is also on a deprecation
path, with no plans for a migration path to `external-secrets`.

`external-secrets` is less mature and slightly more complex, but not significantly so, and proof of concept tests did
not raise any significant issues.

Given that the SIG have destined `kubernetes-external-secrets` for deprecation, we should invest our time in the future-facing
project, even though it is still in a relatively early stage.

## Consequences

We might find more than average numbers of bugs and changes as the project is in a relatively early stage.

We must establish the structure of secrets in AWS, and IAM roles and access patterns. We will cover them in a future ADR.

To maintain end-to-end encryption of secrets, we will enable 
[Key Management Service encryption for Kubernetes Secrets](https://aws.amazon.com/about-aws/whats-new/2020/03/amazon-eks-adds-envelope-encryption-for-secrets-with-aws-kms/).

Secret rotation does not automatically restart secrets-consuming `Pods`; this is true of all three projects. We would 
require a separate component [such as `Reloader`](https://github.com/stakater/Reloader) to implement this.
