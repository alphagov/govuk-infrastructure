# 10. Use Dex IdP for user web auth

Date: 2021-12-01

## Status

Accepted

## Context

We want to implement user authentication on the monitoring stack's web applications (Grafana, Prometheus, Alertmanager). We also want to use Github as the identity provider (IdP), as that provides a means for us to control access based on GDS Github organisation and team membership.

Grafana supports many authentication methods, including [Github OAuth2](https://grafana.com/docs/grafana/latest/auth/github/) and [OIDC (via generic OAuth2)](https://grafana.com/docs/grafana/latest/auth/generic-oauth/).

Prometheus and Alertmanager do not support any form of web-based user authentication, so this must be handled via a proxy or load balancer in front of the application.

We are currently using ALBs in front of Prometheus and Alertmanager, via the [AWS Load Balancer Controller](0004-use-aws-load-balancer-controller-for-edge-traffic-services.md), which supports [authentication via AWS Cognito or OIDC-compliant identity providers](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/ingress/annotations/#authentication).

Github as an IdP does not support OIDC, only OAuth2, so cannot be used with ALB auth. AWS Cognito [does not support OAuth2, only OIDC](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-identity.html), so cannot be used with Github as an IdP.

ArgoCD, our current CD tool, also [implements authentication via OIDC](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/#existing-oidc-provider), and [includes an OIDC-compliant identity broker](https://argoproj.github.io/argo-workflows/argo-server-sso-argocd/), [Dex](https://dexidp.io).

In summary, OIDC is the only auth protocol supported universally by both our current web-based UIs that support authentication internally, and by ALBs for apps that do not. Github however does not provide an OIDC-compliant IdP.

## Decision

Use [Dex](https://dexidp.io) as an SSO service and identity provider for all web-based user authentication. This is strictly for use with user-facing web-based cluster services such as monitoring and CI/CD tools, and should not be used for any other purposes such as AWS or Kubernetes authentication.

## Consequences

We will have a single signon (SSO) service for all user-facing platform UIs, now and in the future. This will provide a single point of integration with the underlying identity provider (Github), and so only one component will need a configuration change in the event that the identity provider changes in the future (for example, to Google or Active Directory).

Dex is currently deployed as a component of the larger Argo service. As Dex will now be a shared platform service, this should be removed in favour of a standalone Dex [Helm install](https://github.com/dexidp/helm-charts).

As a single signon service, Dex is also a single point of failure and a clear potential target for attack. As such Dex must be highly available, secure, and covered in the scope of penetration testing.
