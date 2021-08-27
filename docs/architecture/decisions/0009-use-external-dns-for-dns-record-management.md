# 9. Use external-dns for DNS record management

Date: 2021-08-27

## Status

Accepted

## Context

We want to be able to manage DNS records for Kubernetes `Ingress` and `Service type=Loadbalancer` resources declaratively via Kubernetes resources, so that we avoid the overhead and brittleness of manual DNS management with Terraform.

[`external-dns`](https://github.com/kubernetes-sigs/external-dns) is the primary project in this space and gives us everything we need; Route53 integration, support for all AWS load balancer types, integration with [`alb-ingress-controller`](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/alb-ingress.md) and [IRSA](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) support.

## Decision

Use [`external-dns`](https://github.com/kubernetes-sigs/external-dns).

## Consequences

Can be installed via [a Helm chart](https://artifacthub.io/packages/helm/bitnami/external-dns).

`Ingress` and `Service` resources can configure a DNS record with a simple annotation:

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    external-dns.alpha.kubernetes.io/hostname: foo.test.govuk.digital
```
