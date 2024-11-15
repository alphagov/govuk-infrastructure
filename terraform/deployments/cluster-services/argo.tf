# Installs and configures ArgoCD for deploying GOV.UK apps
locals {
  argo_host           = "argo.${local.external_dns_zone_name}"
  argo_workflows_host = "argo-workflows.${local.external_dns_zone_name}"
  argo_metrics_config = {
    enabled = true
    serviceMonitor = {
      enabled   = true
      namespace = local.monitoring_ns
    }
  }
  argo_environment_banner_background_colors = {
    test        = "#5694ca"
    integration = "#ffdd00"
    staging     = "#f47738"
    production  = "#d4351c"
  }
  argo_environment_banner_foreground_colors = {
    test        = "#000000"
    integration = "#000000"
    staging     = "#000000"
    production  = "#ffffff"
  }
}

resource "kubernetes_namespace" "apps" {
  metadata {
    name = var.apps_namespace
    annotations = {
      "argocd.argoproj.io/sync-options" = "ServerSideApply=true"
    }
    labels = {
      "app.kubernetes.io/managed-by"  = "Terraform"
      "argocd.argoproj.io/managed-by" = "cluster-services"
      # https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/pod_readiness_gate/
      "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled"
      "pod-security.kubernetes.io/audit"        = "restricted"
      "pod-security.kubernetes.io/enforce"      = "baseline"
      "pod-security.kubernetes.io/warn"         = "restricted"
    }
  }
}

resource "helm_release" "argo_cd" {
  chart            = "argo-cd"
  name             = "argo-cd"
  namespace        = local.services_ns
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "7.1.4" # TODO: Dependabot or equivalent so this doesn't get neglected.
  timeout          = var.helm_timeout_seconds
  values = [yamlencode({
    global = {
      logging = {
        format = "json"
        level  = "warn"
      }
    }

    configs = {
      cm = {
        url = "https://${local.argo_host}"
        "oidc.config" = yamlencode({
          name         = "GitHub"
          issuer       = "https://${local.dex_host}"
          clientID     = "$govuk-dex-argocd:clientID"
          clientSecret = "$govuk-dex-argocd:clientSecret"
        })
      }

      # We terminate TLS at the ALB (L7 LB inside the VPC network), so tell
      # argo-cd-server not to redirect to HTTPS.
      params = { "server.insecure" = true }

      rbac = {
        "policy.csv" = <<-EOT
          g, ${var.github_read_only_team}, role:readonly
          g, ${var.github_read_write_team}, role:admin
          EOT
      }

      # Adds some hacky custom CSS that inserts an environment banner into the ArgoCD UI to make it
      # easier to differentiate between environments. May break if there are major changes to the
      # ArgoCD UI.
      styles = templatefile("${path.module}/templates/argo-custom-css.tpl", {
        env_name             = title(var.govuk_environment)
        env_abbreviation     = upper(substr(var.govuk_environment, 0, 1))
        env_background_color = local.argo_environment_banner_background_colors[var.govuk_environment]
        env_foreground_color = local.argo_environment_banner_foreground_colors[var.govuk_environment]
      })
    }

    controller = { metrics = local.argo_metrics_config }

    server = {
      replicas = var.desired_ha_replicas

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
        hostname         = local.argo_host
        tls              = true
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
        hostname         = local.argo_host
        tls              = true
      }

      metrics = local.argo_metrics_config
    }

    repoServer = {
      metrics  = local.argo_metrics_config
      replicas = var.desired_ha_replicas
    }

    applicationSet = { replicas = var.desired_ha_replicas }
    dex            = { enabled = false }

    notifications = {
      argocdUrl = "https://${local.argo_host}"
      cm        = { create = false }
      secret    = { create = false }
      metrics   = local.argo_metrics_config
    }
  })]
}

resource "helm_release" "argo_bootstrap" {
  # Relies on CRDs
  depends_on       = [helm_release.argo_cd]
  chart            = "argo-bootstrap"
  name             = "argo-bootstrap"
  namespace        = local.services_ns
  create_namespace = true
  repository       = "https://alphagov.github.io/govuk-helm-charts/"
  version          = "0.3.2" # TODO: Dependabot or equivalent so this doesn't get neglected.
  timeout          = var.helm_timeout_seconds
  values = [yamlencode({
    # TODO: This TF module should not need to know the govuk_environment, since
    # there is only one per AWS account.
    awsAccountId     = data.aws_caller_identity.current.account_id
    govukEnvironment = var.govuk_environment
    argocdUrl        = "https://${local.argo_host}"
    argoWorkflowsUrl = "https://${local.argo_workflows_host}"
    rbacTeams = {
      read_only  = var.github_read_only_team
      read_write = var.github_read_write_team
    }
    iamRoleServiceAccounts = {
      tagImageWorkflow = {
        name       = local.tag_image_service_account_name
        iamRoleArn = module.tag_image_iam_role.iam_role_arn
      }
    }
  })]
}

resource "helm_release" "argo_workflows" {
  chart            = "argo-workflows"
  name             = "argo-workflows"
  namespace        = local.services_ns
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "0.42.7" # TODO: Dependabot or equivalent so this doesn't get neglected.
  timeout          = var.helm_timeout_seconds
  values = [yamlencode({
    controller = {
      podSecurityContext = {
        runAsNonRoot = true
        seccompProfile = {
          type = "RuntimeDefault"
        }
      }
      securityContext = {
        readOnlyRootFilesystem   = true
        allowPrivilegeEscalation = false
        capabilities = {
          drop = ["ALL"]
        }
      }
      workflowNamespaces = concat([local.services_ns], var.argo_workflows_namespaces)
      workflowDefaults = {
        spec = {
          # The default service account is managed by argo-services in govuk-helm-charts
          serviceAccountName    = "argo-workflow-default"
          activeDeadlineSeconds = 7200
          ttlStrategy = {
            secondsAfterFailure    = 259200
            secondsAfterSuccess    = 259200
            secondsAfterCompletion = 259200
          }
          podGC = { strategy = "OnWorkflowSuccess" }
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
      replicas        = var.desired_ha_replicas
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
      serviceAccount = { create = false }
      rbac           = { create = false }
    }

    server = {
      authModes = ["client", "sso"]
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
        enabled = true
        issuer  = "https://${local.dex_host}"
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
        rbac        = { enabled = true }
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
      podSecurityContext = {
        runAsNonRoot = true
        seccompProfile = {
          type = "RuntimeDefault"
        }
      }
      securityContext = {
        readOnlyRootFilesystem   = true
        allowPrivilegeEscalation = false
        capabilities = {
          drop = ["ALL"]
        }
      }
      replicas = var.desired_ha_replicas
    }
  })]
}
