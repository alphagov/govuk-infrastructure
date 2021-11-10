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

resource "helm_release" "argo_services" {
  # Relies on CRDs
  depends_on = [helm_release.argo_cd, helm_release.argo_events]
  chart      = "argo-services"
  name       = "argo-services"
  namespace  = local.services_ns
  repository = "https://alphagov.github.io/govuk-helm-charts/"
  version    = "0.1.1" # TODO: Dependabot or equivalent so this doesn't get neglected.
  values = [yamlencode({
    # TODO: This TF module should not need to know the govuk_environment, since
    # there is only one per AWS account.
    govukEnvironment = var.govuk_environment
    argocdUrl        = "https://${local.argo_host}"
  })]
}

resource "helm_release" "argo_notifications" {
  chart      = "argocd-notifications"
  name       = "argocd-notifications"
  namespace  = local.services_ns
  repository = "https://argoproj.github.io/argo-helm"
  version    = "1.5.1" # TODO: Dependabot or equivalent so this doesn't get neglected.
  values = [yamlencode({
    # Configured in argo-services Helm chart
    cm = {
      create = false
    }
    "argocdUrl" = "https://${local.argo_host}"

    # argocd-notifications-secret will be created by ExternalSecrets
    # since the secrets are stored in AWS SecretsManager
    secret = {
      create = false
    }
  })]
}

resource "helm_release" "argo_workflows" {
  chart      = "argo-workflows"
  name       = "argo-workflows"
  namespace  = local.services_ns
  repository = "https://argoproj.github.io/argo-helm"
  version    = "0.8.0" # TODO: Dependabot or equivalent so this doesn't get neglected.
  values = [yamlencode({
    controller = {
      workflowNamespaces = concat([local.services_ns], var.argo_workflow_namespaces)
    }

    workflow = {
      serviceAccount = {
        create = true
      }
    }
  })]
}

resource "helm_release" "argo_events" {
  chart      = "argo-events"
  name       = "argo-events"
  namespace  = local.services_ns
  repository = "https://argoproj.github.io/argo-helm"
  version    = "1.7.0" # TODO: Dependabot or equivalent so this doesn't get neglected.
  values = [yamlencode({
    namespace = local.services_ns
  })]
}
