# Dex client credentials

locals {
  dex_clients = toset([
    "alertmanager",
    "prometheus",
    "grafana",
    "argocd",
    "argo-workflows"
  ])
  dex_client_namespaces = [
    local.services_ns,
    var.apps_namespace,
    local.monitoring_ns
  ]

  dex_clients_namespaces = {
    for pair in setproduct(local.dex_clients, local.dex_client_namespaces) : "${pair[1]}-${pair[0]}" => { namespace = pair[1], client = pair[0] }
  }
}

resource "random_bytes" "dex_id" {
  for_each = local.dex_clients

  length = 8
}

resource "random_password" "dex_secret" {
  for_each = local.dex_clients

  length  = 32
  special = false
  lower   = true
  upper   = false
  numeric = true
}

resource "random_password" "dex_cookie_secret" {
  for_each = local.dex_clients

  length  = 32
  special = false
  lower   = true
  upper   = false
  numeric = true
}

resource "kubernetes_secret" "dex_client" {
  for_each = local.dex_clients_namespaces
  depends_on = [
    kubernetes_namespace.apps,
    kubernetes_namespace.monitoring,
    # we depend on the namespace existing
    # but aren't managing it explicitly in TF
    # so we need to depend on something that will
    # create it implicitly
    helm_release.aws_lb_controller
  ]

  metadata {
    name      = "dex-client-${each.value.client}"
    namespace = each.value.namespace
  }
  data = {
    clientID     = random_bytes.dex_id[each.value.client].hex
    clientSecret = random_password.dex_secret[each.value.client].result
    cookieSecret = random_password.dex_cookie_secret[each.value.client].result
  }

  lifecycle {
    ignore_changes = [metadata[0].labels]
  }
}

# Ephemeral account credentials

resource "random_uuid" "eph_account" {}

resource "random_password" "eph_account" {
  length = 32

  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "kubernetes_secret" "eph_account" {
  count      = startswith(var.govuk_environment, "eph-") ? 1 : 0
  depends_on = [helm_release.dex]

  metadata {
    name      = "dex-account"
    namespace = "cluster-services"
  }

  data = {
    username = "admin"
    password = random_password.eph_account.result
  }
}

locals {
  # this list will only have a value in it if
  # we are in an ephemeral environment
  dex_static_passwords = startswith(var.govuk_environment, "eph-") ? [
    {
      username = "admin"
      hash     = random_password.eph_account.bcrypt_hash
      email    = "ephemeral-user@digital.cabinet-office.gov.uk"
      userID   = random_uuid.eph_account.result
    }
  ] : []
  dex_enable_passworddb = startswith(var.govuk_environment, "eph-")

  dex_connectors = startswith(var.govuk_environment, "eph-") ? [] : [
    {
      type = "github"
      id   = "github"
      name = "GitHub"
      config = {
        clientID      = "$GITHUB_CLIENT_ID"
        clientSecret  = "$GITHUB_CLIENT_SECRET"
        redirectURI   = "https://${local.dex_host}/callback"
        orgs          = var.dex_github_orgs_teams
        teamNameField = "both"
        useLoginAsID  = true
      }
    }
  ]

  dex_github_env_var = startswith(var.govuk_environment, "eph-") ? [] : [
    {
      name = "GITHUB_CLIENT_ID"
      valueFrom = {
        secretKeyRef = {
          name = "govuk-dex-github"
          key  = "clientID"
        }
      }
    },
    {
      name = "GITHUB_CLIENT_SECRET"
      valueFrom = {
        secretKeyRef = {
          name = "govuk-dex-github"
          key  = "clientSecret"
        }
      }
    }
  ]

  dex_env_vars = concat(
    local.dex_github_env_var,
    [
      {
        name = "ARGO_WORKFLOWS_CLIENT_ID"
        valueFrom = {
          secretKeyRef = {
            name = "dex-client-argo-workflows"
            key  = "clientID"
          }
        }
      },
      {
        name = "ARGO_WORKFLOWS_CLIENT_SECRET"
        valueFrom = {
          secretKeyRef = {
            name = "dex-client-argo-workflows"
            key  = "clientSecret"
          }
        }
      },
      {
        name = "ARGOCD_CLIENT_ID"
        valueFrom = {
          secretKeyRef = {
            name = "dex-client-argocd"
            key  = "clientID"
          }
        }
      },
      {
        name = "ARGOCD_CLIENT_SECRET"
        valueFrom = {
          secretKeyRef = {
            name = "dex-client-argocd"
            key  = "clientSecret"
          }
        }
      },
      {
        name = "GRAFANA_CLIENT_ID"
        valueFrom = {
          secretKeyRef = {
            name = "dex-client-grafana"
            key  = "clientID"
          }
        }
      },
      {
        name = "GRAFANA_CLIENT_SECRET"
        valueFrom = {
          secretKeyRef = {
            name = "dex-client-grafana"
            key  = "clientSecret"
          }
        }
      },
      {
        name = "PROMETHEUS_CLIENT_ID"
        valueFrom = {
          secretKeyRef = {
            name = "dex-client-prometheus"
            key  = "clientID"
          }
        }
      },
      {
        name = "PROMETHEUS_CLIENT_SECRET"
        valueFrom = {
          secretKeyRef = {
            name = "dex-client-prometheus"
            key  = "clientSecret"
          }
        }
      },
      {
        name = "ALERT_MANAGER_CLIENT_ID"
        valueFrom = {
          secretKeyRef = {
            name = "dex-client-alertmanager"
            key  = "clientID"
          }
        }
      },
      {
        name = "ALERT_MANAGER_CLIENT_SECRET"
        valueFrom = {
          secretKeyRef = {
            name = "dex-client-alertmanager"
            key  = "clientSecret"
          }
        }
      }
    ]
  )
}

resource "helm_release" "dex" {
  depends_on       = [helm_release.aws_lb_controller, helm_release.cluster_secrets]
  chart            = "dex"
  name             = "dex"
  namespace        = local.services_ns
  create_namespace = true
  repository       = "https://charts.dexidp.io"
  version          = "0.23.0"
  values = [yamlencode({
    replicaCount = var.desired_ha_replicas
    config = {
      issuer = "https://${local.dex_host}"

      oauth2 = {
        skipApprovalScreen = true
      }

      storage = {
        type = "kubernetes"
        config = {
          inCluster = true
        }
      }

      # static account for ephemeral environments
      enablePasswordDB = local.dex_enable_passworddb
      staticPasswords  = local.dex_static_passwords

      connectors = local.dex_connectors

      # staticClients uses a different method for expansion of environment
      # variables, see [bug](https://github.com/gabibbo97/charts/issues/36#issuecomment-736911424)
      staticClients = [
        {
          name         = "argo-workflows"
          idEnv        = "ARGO_WORKFLOWS_CLIENT_ID"
          secretEnv    = "ARGO_WORKFLOWS_CLIENT_SECRET"
          redirectURIs = ["https://${local.argo_workflows_host}/oauth2/callback"]
        },
        {
          name         = "argocd"
          idEnv        = "ARGOCD_CLIENT_ID"
          secretEnv    = "ARGOCD_CLIENT_SECRET"
          redirectURIs = ["https://${local.argo_host}/auth/callback"]
        },
        {
          name         = "grafana"
          idEnv        = "GRAFANA_CLIENT_ID"
          secretEnv    = "GRAFANA_CLIENT_SECRET"
          redirectURIs = ["https://${local.grafana_host}/login/generic_oauth"]
        },
        {
          name         = "prometheus"
          idEnv        = "PROMETHEUS_CLIENT_ID"
          secretEnv    = "PROMETHEUS_CLIENT_SECRET"
          redirectURIs = ["https://${local.prometheus_host}/oauth2/callback"]
        },
        {
          name         = "alert-manager"
          idEnv        = "ALERT_MANAGER_CLIENT_ID"
          secretEnv    = "ALERT_MANAGER_CLIENT_SECRET"
          redirectURIs = ["https://${local.alertmanager_host}/oauth2/callback"]
        }
      ]
    }

    envVars = local.dex_env_vars

    service = {
      ports = {
        http = {
          port = 80
        }
        https = {
          port = 443
        }
      }
    }

    ingress = {
      enabled = true
      annotations = {
        "alb.ingress.kubernetes.io/group.name"         = "dex-${var.govuk_environment}"
        "alb.ingress.kubernetes.io/scheme"             = "internet-facing"
        "alb.ingress.kubernetes.io/target-type"        = "ip"
        "alb.ingress.kubernetes.io/load-balancer-name" = "dex"
        "alb.ingress.kubernetes.io/listen-ports"       = jsonencode([{ "HTTP" : 80 }, { "HTTPS" : 443 }])
        "alb.ingress.kubernetes.io/ssl-redirect"       = "443"
      }
      className = "aws-alb"
      hosts = [
        {
          host = local.dex_host
          paths = [
            {
              path     = "/*"
              pathType = "ImplementationSpecific"
            }
          ]
        }
      ]
    }
  })]
}
