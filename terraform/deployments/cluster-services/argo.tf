# Installs and configures ArgoCD for deploying GOV.UK apps
locals {
  argo_host           = "argo.${local.external_dns_zone_name}"
  argo_workflows_host = "argo-workflows.${local.external_dns_zone_name}"
  argo_events_host    = "argo-events.${local.external_dns_zone_name}"
  argo_metrics_config = {
    enabled = true
    serviceMonitor = {
      enabled   = true
      namespace = local.monitoring_ns
    }
  }
}

resource "kubernetes_namespace" "apps" {
  metadata {
    name = var.apps_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "Terraform"
      # https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/pod_readiness_gate/
      "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled"
    }
  }
}

resource "helm_release" "argo_cd" {
  depends_on       = [helm_release.dex]
  chart            = "argo-cd"
  name             = "argo-cd"
  namespace        = local.services_ns
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "4.9.12" # TODO: Dependabot or equivalent so this doesn't get neglected.
  values = [yamlencode({
    server = {
      # TLS Termination happens at the ALB, the insecure flag prevents Argo
      # server from upgrading the request after TLS termination.
      extraArgs = ["--insecure"]

      replicas = var.default_desired_ha_replicas

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

        "oidc.config" = yamlencode({
          name         = "GitHub"
          issuer       = "https://${local.dex_host}"
          clientID     = "$govuk-dex-argocd:clientID"
          clientSecret = "$govuk-dex-argocd:clientSecret"
        })
      }

      rbacConfig = {
        "policy.csv" = <<-EOT
          g, ${var.github_read_only_team}, role:readonly
          g, ${var.github_read_write_team}, role:admin
          EOT
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

      metrics = local.argo_metrics_config
    }

    controller = {
      metrics = local.argo_metrics_config
    }

    repoServer = {
      metrics  = local.argo_metrics_config
      replicas = var.default_desired_ha_replicas
    }

    applicationSet = {
      replicaCount = var.default_desired_ha_replicas
    }

    dex = {
      enabled = false
    }

    redis-ha = {
      enabled = true
    }

    notifications = {
      argocdUrl = "https://${local.argo_host}"
      cm        = { create = false }
      secret    = { create = false }
      metrics   = local.argo_metrics_config
    }
  })]
}

resource "helm_release" "argo_services" {
  # Relies on CRDs
  depends_on       = [helm_release.argo_cd, helm_release.argo_events]
  chart            = "argo-services"
  name             = "argo-services"
  namespace        = local.services_ns
  create_namespace = true
  repository       = "https://alphagov.github.io/govuk-helm-charts/"
  version          = "0.1.18" # TODO: Dependabot or equivalent so this doesn't get neglected.
  values = [yamlencode({
    # TODO: This TF module should not need to know the govuk_environment, since
    # there is only one per AWS account.
    govukEnvironment     = var.govuk_environment
    argocdUrl            = "https://${local.argo_host}"
    argoEventsHost       = local.argo_events_host
    enableWebhookIngress = (var.govuk_environment == "integration")
    rbacTeams = {
      read_only  = var.github_read_only_team
      read_write = var.github_read_write_team
    }
  })]
}

resource "helm_release" "argo_workflows" {
  # Dex is used to provide SSO facility to Argo-Workflows and there is a bug
  # where Argo Workflows fail to start if Dex is not present
  depends_on       = [helm_release.dex]
  chart            = "argo-workflows"
  name             = "argo-workflows"
  namespace        = local.services_ns
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "0.16.6" # TODO: Dependabot or equivalent so this doesn't get neglected.
  values = [yamlencode({
    controller = {
      podSecurityContext = {
        runAsNonRoot = true
      }
      workflowNamespaces = concat([local.services_ns], var.argo_workflows_namespaces)
      workflowDefaults = {
        spec = {
          activeDeadlineSeconds = 7200
          ttlStrategy = {
            secondsAfterFailure    = 259200
            secondsAfterSuccess    = 259200
            secondsAfterCompletion = 259200
          }
          podGC = {
            strategy = "OnWorkflowSuccess"
          }
          securityContext = {
            runAsNonRoot = true
            runAsUser    = 1001
          }
          podSpecPatch = yamlencode({
            containers = [
              {
                name = "main"
                resources = {
                  requests = {
                    cpu    = "100m"
                    memory = "64Mi"
                  }
                  limits = {
                    cpu    = "500m"
                    memory = "256Mi"
                  }
                }
              }
            ]
          })
        }
      }
      containerRuntimeExecutor = "emissary"
      resources = {
        requests = {
          cpu    = "500m"
          memory = "1Gi"
        }
        limits = {
          cpu    = "1"
          memory = "2Gi"
        }
      }
      workflowWorkers = 128
      replicas        = var.default_desired_ha_replicas
    }

    executor = {
      resources = {
        requests = {
          cpu    = "100m"
          memory = "64Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }
    }

    workflow = {
      serviceAccount = {
        create = true
      }
    }

    server = {
      extraArgs = ["--auth-mode=client", "--auth-mode=sso"]
      ingress = {
        enabled = true
        annotations = {
          "alb.ingress.kubernetes.io/group.name"         = "argo-workflows"
          "alb.ingress.kubernetes.io/scheme"             = "internet-facing"
          "alb.ingress.kubernetes.io/target-type"        = "ip"
          "alb.ingress.kubernetes.io/load-balancer-name" = "argo-workflows"
          "alb.ingress.kubernetes.io/listen-ports"       = jsonencode([{ "HTTP" : 80 }, { "HTTPS" : 443 }])
          "alb.ingress.kubernetes.io/ssl-redirect"       = "443"
        }
        ingressClassName = "aws-alb"
        hosts            = [local.argo_workflows_host]
      }
      sso = {
        issuer = "https://${local.dex_host}"
        clientId = {
          name = "govuk-dex-argo-workflows"
          key  = "clientID"
        }
        clientSecret = {
          name = "govuk-dex-argo-workflows"
          key  = "clientSecret"
        }
        redirectUrl = "https://${local.argo_workflows_host}/oauth2/callback"
        scopes      = ["groups"]
        rbac = {
          enabled = true
        }
      }
      resources = {
        requests = {
          cpu    = "200m"
          memory = "256Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }
      replicas = var.default_desired_ha_replicas
    }
  })]
}

resource "helm_release" "argo_events" {
  chart            = "argo-events"
  name             = "argo-events"
  namespace        = local.services_ns
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "2.0.3" # TODO: Dependabot or equivalent so this doesn't get neglected.
  values = [yamlencode({
    namespace = local.services_ns
    controller = {
      replicas = var.default_desired_ha_replicas
    }
    configs = {
      nats = {
        versions = [
          {
            version              = "0.22.1"
            natsStreamingImage   = "nats-streaming:0.22.1"
            metricsExporterImage = "natsio/prometheus-nats-exporter:0.8.0"
          }
        ]
      }
    }
  })]
}
