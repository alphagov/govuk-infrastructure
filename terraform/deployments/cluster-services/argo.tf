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

  # give everyone admin role in ephemeral envs
  # use GitHub teams in other environments
  argo_rbac_policy = startswith(var.govuk_environment, "eph-") ? {
    "policy.default" = "role:admin"
    } : {
    "policy.csv" = <<-EOT
    g, ${var.github_read_only_team}, role:readonly
    g, ${var.github_read_write_team}, role:admin
    EOT
  }
}

# this label is required for argocd to pick up the secret
# https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/#alternative
resource "kubernetes_labels" "argocd_secret" {
  for_each   = toset(local.dex_client_namespaces)
  depends_on = [kubernetes_secret.dex_client]

  api_version = "v1"
  kind        = "Secret"
  metadata {
    name      = "dex-client-argocd"
    namespace = each.key
  }
  labels = {
    "app.kubernetes.io/part-of" = "argocd"
  }
}

resource "helm_release" "argo_cd" {
  chart            = "argo-cd"
  name             = "argo-cd"
  namespace        = local.services_ns
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "7.8.26" # TODO: Dependabot or equivalent so this doesn't get neglected.
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
          clientID     = "$dex-client-argocd:clientID"
          clientSecret = "$dex-client-argocd:clientSecret"
        })
      }

      # We terminate TLS at the ALB (L7 LB inside the VPC network), so tell
      # argo-cd-server not to redirect to HTTPS.
      params = {
        "server.insecure"                 = true
        "controller.sync.timeout.seconds" = 300
      }

      rbac = local.argo_rbac_policy

      # Adds some hacky custom CSS that inserts an environment banner into the ArgoCD UI to make it
      # easier to differentiate between environments. May break if there are major changes to the
      # ArgoCD UI.
      styles = templatefile("${path.module}/templates/argo-custom-css.tpl", {
        env_name             = title(var.govuk_environment)
        env_abbreviation     = upper(substr(var.govuk_environment, 0, 1))
        env_background_color = lookup(local.argo_environment_banner_background_colors, var.govuk_environment, "#5694ca")
        env_foreground_color = lookup(local.argo_environment_banner_foreground_colors, var.govuk_environment, "#000000")
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
  count = startswith(var.govuk_environment, "eph-") ? 0 : 1
  # Relies on CRDs
  depends_on = [
    helm_release.argo_cd,
    helm_release.external_secrets
  ]
  chart            = "argo-bootstrap"
  name             = "argo-bootstrap"
  namespace        = local.services_ns
  create_namespace = true
  repository       = "https://alphagov.github.io/govuk-helm-charts/"
  version          = "0.3.4" # TODO: Dependabot or equivalent so this doesn't get neglected.
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

resource "helm_release" "argo_bootstrap_ephemeral" {
  count = startswith(var.govuk_environment, "eph-") ? 1 : 0
  # Relies on CRDs
  depends_on = [
    helm_release.argo_cd,
    helm_release.external_secrets
  ]
  chart            = "argo-bootstrap-ephemeral"
  name             = "argo-bootstrap-ephemeral"
  namespace        = local.services_ns
  create_namespace = true
  repository       = "https://alphagov.github.io/govuk-helm-charts/"
  version          = "0.0.11"
  timeout          = var.helm_timeout_seconds
  values = [yamlencode({
    awsAccountId     = data.aws_caller_identity.current.account_id
    govukEnvironment = "ephemeral"
    clusterId        = var.cluster_name
    argocdUrl        = "https://${local.argo_host}"
    argoNamespace    = local.services_ns
    argoWorkflowsUrl = "https://${local.argo_workflows_host}"
    iamRoleServiceAccounts = {
      tagImageWorkflow = {
        name       = local.tag_image_service_account_name
        iamRoleArn = module.tag_image_iam_role.iam_role_arn
      }
    }
  })]
}

resource "helm_release" "argo_workflows" {
  depends_on = [
    kubernetes_secret.dex_client,
    helm_release.aws_lb_controller
  ]

  chart            = "argo-workflows"
  name             = "argo-workflows"
  namespace        = local.services_ns
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "0.45.12" # TODO: Dependabot or equivalent so this doesn't get neglected.
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
            runAsGroup   = 1001
            fsGroup      = 1001
            seccompProfile = {
              type = "RuntimeDefault"
            }
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
      securityContext = {
        readOnlyRootFileSystem   = true
        allowPrivilegeEscalation = false
        capabilities = {
          drop = ["ALL"]
        }
      }
    }

    mainContainer = {
      securityContext = {
        readOnlyRootFileSystem   = true
        allowPrivilegeEscalation = false
        capabilities = {
          drop = ["ALL"]
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
          name = "dex-client-argo-workflows"
          key  = "clientID"
        }
        clientSecret = {
          name = "dex-client-argo-workflows"
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
