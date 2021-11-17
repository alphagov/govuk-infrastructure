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
    "configs" = {
      "knownHosts" = {
        "data" = {
          "ssh_known_hosts" : <<-KNOWN_HOSTS
          github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
          github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
          github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
          KNOWN_HOSTS
        }
      }
    }

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
  version    = "0.1.2" # TODO: Dependabot or equivalent so this doesn't get neglected.
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
