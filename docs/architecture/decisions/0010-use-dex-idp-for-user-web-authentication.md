# 10. Use Dex IdP for user web authentication

Date: 2021-12-01

## Status

Accepted

## Context

We want to implement user authentication on the monitoring stack's web applications (Grafana, Prometheus, Alertmanager).

We also want to use GitHub as the identity provider, because that provides a means for us to control access based on
GDS GitHub organisation and team membership. The alternative option, GSuite, does not have the granular role or group 
structure that we would require to effectively control access, and implementing it be out of scope for us. It would 
likely replicate the GitHub group and team structure that currently exists.

Grafana supports many authentication methods,
including [GitHub OAuth2](https://grafana.com/docs/grafana/latest/auth/github/)
and [Open Identity Connect (OIDC) through generic OAuth2](https://grafana.com/docs/grafana/latest/auth/generic-oauth/).

Prometheus and Alertmanager do not support any form of web-based user authentication, so authentication must happen at a
proxy or load balancer in front of the application.

We are currently using Application Load Balancers (ALB) in front of Prometheus and Alertmanager, from
the [AWS Load Balancer Controller](0004-use-aws-load-balancer-controller-for-edge-traffic-services.md), which
supports [authentication with AWS Cognito or OIDC-compliant identity providers](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/ingress/annotations/#authentication).

GitHub as an identity provider does not support OIDC, only OAuth2, so we cannot use it for ALB authentication. AWS
Cognito [does not support OAuth2, only OIDC](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-identity.html),
so we cannot use it with GitHub as an identity provider.

ArgoCD, our current CD tool,
also [implements authentication with OIDC](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/#existing-oidc-provider),
and [includes an OIDC-compliant identity broker](https://argoproj.github.io/argo-workflows/argo-server-sso-argocd/): [Dex](https://dexidp.io).

In summary, OIDC is the only authentication protocol supported universally by both our current web-based UIs that have
authentication built-in, and by Application Load Balancers for apps that do not. GitHub however does not offer an 
OIDC-compliant identity provider.

## Decision

Use [Dex](https://dexidp.io) as a Single Sign-On (SSO) service and identity provider for all web-based user authentication. 
This is strictly for use with user-facing, web-based cluster services such as monitoring and CI/CD tools. We should not
used it for any other purposes, such as AWS or Kubernetes authentication.

## Consequences

We will have an SSO service and consistent identity provider for all user-facing platform UIs, now and in the future. 
This will give us a single integration with the underlying identity provider, and only one component will need a 
configuration change in the event that the identity provider changes in the future.

Dex is currently deployed as a component of the larger Argo service. It will now be a shared platform service, so we
will remove it in favour of a standalone Dex [Helm chart installation](https://github.com/dexidp/helm-charts).

Being an SSO service, Dex is also a single point of failure and a clear potential target for attack. Therefore, Dex
must be highly available, secure, and covered in the scope of penetration testing.
