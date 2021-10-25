# Installs and configures ArgoCD for deploying GOV.UK apps
locals {
  argo_host = "argo.${local.external_dns_zone_name}"
}

resource "helm_release" "argo_cd" {
  chart      = "argo-cd"
  name       = "argo-cd"
  namespace  = local.services_ns
  repository = "https://argoproj.github.io/argo-helm"
  version    = "3.22.1" # TODO: Dependabot or equivalent so this doesn't get neglected.
  values = [yamlencode({
    server = {
      # TLS Termination happens at the ALB, the insecure flag prevents Argo
      # server from upgrading the request after TLS termination.
      extraArgs = ["--insecure"]

      ingress = {
        enabled = true
        annotations = {
          "alb.ingress.kubernetes.io/group.name"         = "argo"
          "alb.ingress.kubernetes.io/scheme"             = "internet-facing"
          "alb.ingress.kubernetes.io/target-type"        = "ip"
          "alb.ingress.kubernetes.io/load-balancer-name" = "argo"
          "alb.ingress.kubernetes.io/listen-ports"       = jsonencode([{ "HTTP" : 80 }, { "HTTPS" : 443 }])
          "alb.ingress.kubernetes.io/ssl-redirect"       = "443"
        }
        labels           = {}
        ingressClassName = "aws-alb"
        hosts            = [local.argo_host]
        https            = true
      }

      config = {
        url = "https://${local.argo_host}"
      }

      ingressGrpc = {
        enabled  = true
        isAWSALB = true
        annotations = {
          "alb.ingress.kubernetes.io/group.name"         = "argo"
          "alb.ingress.kubernetes.io/scheme"             = "internet-facing"
          "alb.ingress.kubernetes.io/target-type"        = "ip"
          "alb.ingress.kubernetes.io/load-balancer-name" = "argo"
          "alb.ingress.kubernetes.io/listen-ports"       = jsonencode([{ "HTTP" : 80 }, { "HTTPS" : 443 }])
          "alb.ingress.kubernetes.io/ssl-redirect"       = "443"
        }
        labels           = {}
        ingressClassName = "aws-alb"
        hosts            = [local.argo_host]
        https            = true
      }
    }
  })]
}

resource "helm_release" "argo_config" {
  depends_on = [helm_release.argo_cd]
  chart      = "argocd-config"
  name       = "argocd-config"
  namespace  = local.services_ns
  repository = "https://alphagov.github.io/govuk-helm-charts/"
  version    = "0.2.0" # TODO: Dependabot or equivalent so this doesn't get neglected.
  values = [yamlencode({
    # TODO: This TF module should not need to know the govuk_environment, since
    # there is only one per AWS account.
    govukEnvironment = var.govuk_environment
  })]
}
