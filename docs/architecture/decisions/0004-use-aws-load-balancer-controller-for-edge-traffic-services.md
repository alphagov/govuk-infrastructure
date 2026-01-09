<!-- vale RedHat.Headings = NO -->

# 4. Use AWS Load Balancer Controller for edge traffic services

<!-- "AWS Load Balancer Controller" is correctly capitalised as a proper noun -->
<!-- vale RedHat.Headings = YES -->

Date: 2021-08-12

## Status

Accepted

## Context

We require a method of managing and directing external internet traffic into the cluster. Kubernetes
provides [several options for handling inbound traffic](https://medium.com/google-cloud/kubernetes-nodeport-vs-loadbalancer-vs-ingress-when-should-i-use-what-922f010849e0).

We do not want to expose the cluster directly to the internet, so we require an AWS load balancer in front of the
cluster. The load balancer must support TLS termination and integration with our DNS provider (AWS Route 53).

Historically, Kubernetes has supported provisioning of Application Load Balancers (ALBs) and Network Load Balancers (NLBs)
for `Service` resources of `type=LoadBalancer` using the in-tree (built-in) [AWS cloud provider](https://github.com/kubernetes/cloud-provider-aws).`Ingress` resources
have always been supported by out-of-tree controllers required. 

Built-in cloud providers are now [considered deprecated overall, in favour of out-of-tree providers](https://kubernetes.io/blog/2019/04/17/the-future-of-cloud-providers-in-kubernetes/),
so users are now required to use an [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/) 
with support for `Service` resources.

The primary, and recommended, ingress controller for AWS' Elastic Kubernetes Service (EKS) is
the [AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html), which can provision and manage [ALBs for `Ingress` resources and NLBs for
`Service` resources](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/#aws-load-balancer-controller).

We must also consider how Kubernetes edge services and AWS load balancers will interact with the existing
[GOV.UK Router service](https://github.com/alphagov/router), because there is significant overlap in their functionality and responsibilities. 
This will require further investigation, so we should be able to use both `Ingress` and `Service` 
Kubernetes resources. This will ensure we have the flexibility to support a wide range of use cases in the immediate 
term: layer 4 and layer 7 traffic, name-based routing, HTTP-to-HTTPS redirection.

## Decision

Use the [AWS Load Balancer Controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller).

## Consequences

The AWS Load Balancer Controller supports TLS certificates with AWS Certificate Manager only. A future ADR will cover the
way in which we use AWS Certificate Manager.

The load balancer controller does not handle DNS for declared ingress host names. A future ADR will cover a solution to 
this.

We will need to establish an appropriate Application and Network Load Balancer topography: how many load balancers routing
to where. By default the controller will provision one load balancer per `Ingress` resource, which might not be what we want.
<!-- vale RedHat.PassiveVoice = NO --> 
Ingresses [can be grouped](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/#ingressgroup),
however.
<!-- "be grouped" is the correct verbiage. It's a valid use of passive voice -->
<!-- vale RedHat.PassiveVoice = YES -->

The load balancer controller
supports [AWS Web Application Firewall and Shield](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/#addons),
both of which are currently in use on GOV.UK.

<!-- vale RedHat.PassiveVoice = NO -->
<!-- vale RedHat.SentenceLength = NO -->

We must also investigate access control for Ingress rules, likely in conjunction with Kubernetes `namespace` usage. If all
of GOV.UK is deployed into a single namespace, and many users or service accounts have the same level of access to
`Ingress` objects, then user or process for component A could modify or destroy ingress rules for component B.

<!-- This paragraph makes sense and is not too long. It's just longer than the usual rule would allow for -->
<!-- vale RedHat.PassiveVoice = YES -->
<!-- vale RedHat.SentenceLength = YES -->