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
  version    = "0.1.2" # TODO: Dependabot or equivalent so this doesn't get neglected.
  values = [yamlencode({
    # TODO: This TF module should not need to know the govuk_environment, since
    # there is only one per AWS account.
    govukEnvironment = var.govuk_environment
  })]
}

resource "helm_release" "argo_notifications" {
  chart      = "argocd-notifications"
  name       = "argocd-notifications"
  namespace  = local.services_ns
  repository = "https://argoproj.github.io/argo-helm"
  version    = "1.5.1" # TODO: Dependabot or equivalent so this doesn't get neglected.
  values = [yamlencode({
    argocdUrl = "https://${local.argo_host}"

    # argocd-notifications-secret will be created by ExternalSecrets
    # since the secrets are stored in AWS SecretsManager
    secret = {
      create = false
    }

    notifiers = {
      # this slack webhook (managed by IT Services) allows messages on the `govuk-deploy-alerts` channel 
      "service.webhook.slack_webhook" = yamlencode({
        url = "$slack_url"
        headers = [{
          name  = "Content-Type"
          value = "application/json"
        }]
      })
      "service.slack" = null # remove default unconfigured slack service to remove misconfiguration error
    }

    triggers = {
      "trigger.sync-operation-change" = yamlencode([
        {
          when    = "app.status.operationState.phase in ['Succeeded'] and app.status.health.status == 'Healthy'"
          oncePer = "app.status.sync.revision"
          send    = ["send-slack"]
        },
        {
          when    = "app.status.operationState.phase in ['Running']"
          oncePer = "app.status.sync.revision"
          send    = ["send-slack"]
        },
        {
          when    = "app.status.operationState.phase in ['Error', 'Failed']"
          oncePer = "app.status.sync.revision"
          send    = ["send-slack"]
        },
      ])
    }

    templates = {
      "template.send-slack" = yamlencode({
        webhook = {
          slack_webhook = {
            method = "POST"
            body   = <<-EOB
            {
              "attachments": [{
                "title": "{{.app.metadata.name}}",
                "title_link": "{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
                {{- if eq .app.status.operationState.phase "Succeeded" -}}
                "color": "#18be52",
                {{- else if eq .app.status.operationState.phase "Running" -}}
                "color": "#beb618",
                {{- else if or (eq .app.status.operationState.phase "Error") (eq .app.status.operationState.phase "Failed") -}}
                "color": "#be1b18",
                {{- else -}}
                "color": "#183cbe",
                {{- end -}}
                "fields": [{
                  "title": "state",
                  "value": "{{.app.status.operationState.phase}}",
                  "short": true
                }]
              }]
            }
            EOB
          }
        }
      })
    }
  })]
}
