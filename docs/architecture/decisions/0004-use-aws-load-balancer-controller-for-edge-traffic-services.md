# 4. Use AWS Load Balancer Controller for edge traffic services

Date: 2021-08-12

## Status

Accepted

## Context

We require a method of managing and directing external internet traffic into the cluster. Kubernetes provides [several options for handling inbound traffic](https://medium.com/google-cloud/kubernetes-nodeport-vs-loadbalancer-vs-ingress-when-should-i-use-what-922f010849e0).

We do not want to expose the cluster directly to the internet, and so require an AWS load balancer in front of the cluster. The load balancer must support TLS termination and integration with our DNS provider (AWS Route 53).

Historically Kubernetes has supported provisioning of ALBs and NLBs for `Service` resources of `type=LoadBalancer` via the in-tree (built-in) [AWS cloud provider](https://github.com/kubernetes/cloud-provider-aws), with out-of-tree controllers required for `Ingress` resources. Built-in cloud providers are now [considered deprecated overall, in favour of out-of-tree providers](https://kubernetes.io/blog/2019/04/17/the-future-of-cloud-providers-in-kubernetes/), so an [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/) with support for `Service` resources is required.

The primary and recommended ingress controller for AWS/EKS is the [AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html), which can provision and manage [ALBs for `Ingress` resources and NLBs for `Service` resources](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/#aws-load-balancer-controller).

We must also consider how Kubernetes edge services and AWS load balancers will interact with the existing [GOV.UK Router service](https://github.com/alphagov/router), as there is significant overlap in their functionality and responsibilities. This will require further investigation and likely experimentation, and so that end we should ensure that we're able to use both `Ingress` and `Service` Kubernetes resources so that we have the flexibility to support a wide range of use cases in the immediate term - L4 & L7 traffic, name-based routing, HTTP->HTTPS redirection, etc.

## Decision

Use the [AWS Load Balancer Controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller).

## Consequences

The AWS Load Balancer Controller supports TLS certificates via AWS Certificate Manager only, so certificates must be managed there (to be covered in a future ADR).

The load balancer controller does not handle DNS for declared ingress hostnames - a solution to this will be covered in a future ADR.

An appropriate ALB/NLB topography (how many LBs routing to where) will need to be established - by default the controller will provision one ALB per `Ingress` resource, which may not be what we want. Ingresses [can be grouped however](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/#ingressgroup).

The load balancer controller supports [AWS WAF and Shield](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/#addons), both of which are currently in use on GOV.UK.

Access control for Ingress rules must be investigated, likely in conjunction with Kubernetes `namespace` usage - if all of GOV.UK is deployed into a single namespace, and multiple users or service accounts have the same level of access to `Ingress` objects, then user or process for component A could modify or destroy ingress rules for component B.
