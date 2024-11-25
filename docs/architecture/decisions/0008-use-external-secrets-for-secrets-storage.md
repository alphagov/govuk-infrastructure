# 8. Use external-secrets for secrets storage

Date: 2021-08-26

## Status

Accepted

## Context

We want to make use of AWS Secrets Manager for secrets storage, rather then relying solely on Kubernetes secrets, as we want the ability to reconstitute the full state of a running cluster from an external source of truth. In most cases that external source of truth is a git repository, but there are significant challenges and pain points when managing sensitive config in git repositories, hence the choice of AWS Secrets Manager.

We must maintain end-to-end encryption of secrets, up until the point where a secret is consumed by a running container, where the secret must necessarily be decrypted for use.

We must be able to enforce access control on secrets, following the principle of least privilege.

We must be able to support rotation of secrets in AWS Secrets Manager, where a change of value in AWS is automatically propagated to services in the cluster.

Secrets should be provided to Kubernetes pods as Kubernetes `Secret` resources, to allow the use of standard patterns and existing third party Kubernetes projects (primarily via Helm charts). The use of a externally-managed secrets should have a minimal impact on development teams and Helm chart/Kubernetes resource authors, with the AWS Secrets Manager integration managed at a cluster level rather than on a per-app basis.

Several projects exist to provide AWS Secrets Manager integration with Kubernetes Secrets, the most notable being:

- [Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io)
- [external-secrets](https://github.com/external-secrets/external-secrets)
- [kubernetes-external-secrets](https://github.com/external-secrets/kubernetes-external-secrets)

Secrets Store CSI is a [Kubernetes SIG](https://github.com/kubernetes/community/blob/master/sig-list.md) project, and aims to provide external secrets to Kubernetes clusters via the [Container Storage Interface](https://kubernetes.io/blog/2019/01/15/container-storage-interface-ga/), a standard for exposing file and block interfaces to containers via plugins (e.g. [AWS EBS CSI driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)).

`external-secrets` and `kubernetes-external-secrets` are closely-related projects that have been brought together as part of the [external-secrets](https://github.com/external-secrets) Github org (and yes, these names are confusing), which has worked to unify multiple projects in this space and create a [single specification for an external secrets Custom Resource Definition](https://github.com/external-secrets/crd-spec/blob/main/Spec.md).

`external-secrets` is the successor project to `kubernetes-external-secrets`, which rewrites the [Operator](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/) in Go rather than Javascript, adopts the standardised CRD and changes the resource object model to separate out secrets consumption in the application and the specific access and authentication/authorization implementation for a given external secrets backend. Both projects support AWS Secrets Manager, as well as Hashicorp Vault and GCP/Azure equivalents. The project maintainers view `kubernetes-external-secrets` as on a deprecation path, and `external-secrets` is currently classed as alpha:

> [Kubernetes External Secrets]: a very popular solution that came from within Godaddy and was written in JS and supports a lot of providers (but will be deprecated)
>
> [External Secrets]: New solution written in golang, aspires to support all the same providers, but we are still working on getting most of the providers stable and out of alpha. Eventually, the idea is to substitute KES. Anyways the migration is pretty much like @Flydiverny said since retro-compatibility with original solutions was not something that we aimed for. Completely new CRD and all that.


(from [Kubernetes Slack](https://kubernetes.slack.com/archives/C017BF84G2Y/p1626186324108900?thread_ts=1626104012.105800&cid=C017BF84G2Y))

Proofs of concept have been carried out on all three options:

1. **Secrets Store CSI** - works, but relatively complex to get up and running. Secrets rotation and syncing with Kubernetes `Secrets` currently experimental/alpha. The use of CSI volumes as an abstraction [requires that secrets be mounted as a volume](https://secrets-store-csi-driver.sigs.k8s.io/topics/sync-as-kubernetes-secret.html) on disk even when secrets are only consumed as env vars by containers. Secrets volume definition in Pods/Deployments is quite verbose and something of a leaky abstraction, as the CSI driver and volume attributes must be specified. Overall CSI feels like the wrong abstraction for external secret stores, as they are fundamentally neither file nor block storage.
2. **`kubernetes-external-secrets`** - Quick and easy to get up and running and simple to use within an application as only one resource (`ExternalSecret`) is required. Works as expected with [IRSA](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html). In-cluster secrets access control is [relatively basic and coarse-grained](https://github.com/external-secrets/kubernetes-external-secrets#scoping-access). Does not support a highly-available deployment (multiple replicas) without the risk of excessive API calls or race conditions.
3. **`external-secrets`** - More complex to get up and running than `kubernetes-external-secrets`, less so than Secrets Store CSI. Documentation is somewhat thin, although the [API spec](https://external-secrets.io/spec/) is comprehensive. Supports [multiple modes of operation for multi-tenancy](https://external-secrets.io/guides-multi-tenancy/) and access control. Project is still in a relatively early stage, so APIs may change. Supports highly available deployments via leadership election.

While multi-tenancy is not a primary concern at this stage, we may discover a need for some level of access control and segregation as more applications are introduced.

## Decision

Use [**`external-secrets`**](https://external-secrets.io).

While `kubernetes-external-secrets` is more mature and slightly simpler to deploy and use, it is also on a deprecation path, with no plans for a migration path to `external-secrets`.

`external-secrets` is less mature and slightly more complex, but not significantly so, and proof of concept tests did not raise any significant issues.

Given that `kubernetes-external-secrets` is destined for deprecation we should invest our time in the future-facing project, even though it is still in a relatively early stage.

## Consequences

We may encounter higher than average levels of bugs and changes as the project is in a relatively early stage.

Structure of secrets in AWS and IAM roles/access patterns must be established (to be covered in a future ADR).

To maintain end-to-end encryption of secrets, [EKS KMS encryption for Kubernetes Secrets](https://aws.amazon.com/about-aws/whats-new/2020/03/amazon-eks-adds-envelope-encryption-for-secrets-with-aws-kms/) must be enabled.

Secret rotation does not automatically restart secrets-consuming Pods (this is true of all three projects) - a separate component such as [Reloader](https://github.com/stakater/Reloader) would be required to implement this.
