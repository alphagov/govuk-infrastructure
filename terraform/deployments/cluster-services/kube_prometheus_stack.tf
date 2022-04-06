# Installs Prometheus Operator, Prometheus, Prometheus rules, Grafana, Grafana dashboards, and Prometheus CRDs

locals {
  alert_manager_host = "alertmanager.${local.external_dns_zone_name}"
  grafana_host       = "grafana.${local.external_dns_zone_name}"
  prometheus_host    = "prometheus.${local.external_dns_zone_name}"
  grafana_iam_role   = data.terraform_remote_state.cluster_infrastructure.outputs.grafana_iam_role_arn
}


resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "34.9.0" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = "monitoring"
  create_namespace = true
  values = [yamlencode({
    alertmanager = {
      ingress = {
        enabled  = true
        hosts    = [local.alert_manager_host]
        pathType = "Prefix"
        annotations = merge(local.alb_ingress_annotations, {
          "alb.ingress.kubernetes.io/load-balancer-name" = "alertmanager"
          "alb.ingress.kubernetes.io/auth-type"          = "oidc"
          "alb.ingress.kubernetes.io/auth-idp-oidc" = jsonencode(
            {
              issuer                = "https://${local.dex_host}"
              authorizationEndpoint = "https://${local.dex_host}/auth"
              tokenEndpoint         = "https://${local.dex_host}/token"
              userInfoEndpoint      = "https://${local.dex_host}/userinfo"
              secretName            = "govuk-dex-alert-manager"
            }
          )
          "alb.ingress.kubernetes.io/auth-on-unauthenticated-request" = "authenticate"
          "alb.ingress.kubernetes.io/auth-scope"                      = "email openid"
        })
      }
    }
    grafana = {
      ingress = {
        enabled  = true
        hosts    = [local.grafana_host]
        pathType = "Prefix"
        annotations = merge(local.alb_ingress_annotations, {
          "alb.ingress.kubernetes.io/load-balancer-name" = "grafana"
        })
      }
      "grafana.ini" = {
        "auth.generic_oauth" = {
          name                = "GitHub"
          enabled             = true
          allow_sign_up       = true
          auth_url            = "https://${local.dex_host}/auth"
          token_url           = "https://${local.dex_host}/token"
          api_url             = "https://${local.dex_host}/userinfo"
          scopes              = "openid profile email groups"
          role_attribute_path = "to_string('Admin')" #TODO: map users/groups to different Grafana roles, e.g. Admin, Viewer, Editor
        }
        server = {
          domain   = local.grafana_host
          root_url = "https://%(domain)s"
        }
        database = {
          type     = "postgres"
          ssl_mode = "disable"
        }
      }
      envValueFrom = {
        "GF_AUTH_GENERIC_OAUTH_CLIENT_ID" = {
          secretKeyRef = {
            name = "govuk-dex-grafana"
            key  = "clientID"
          }
        },
        "GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET" = {
          secretKeyRef = {
            name = "govuk-dex-grafana"
            key  = "clientSecret"
          }
        },
        "GF_DATABASE_HOST" = {
          secretKeyRef = {
            name = "govuk-grafana-database"
            key  = "host"
          }
        },
        "GF_DATABASE_USER" = {
          secretKeyRef = {
            name = "govuk-grafana-database"
            key  = "username"
          }
        },
        "GF_DATABASE_PASSWORD" = {
          secretKeyRef = {
            name = "govuk-grafana-database"
            key  = "password"
          }
        }
      }
      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = local.grafana_iam_role
        }
      }
      env = {
        "AWS_ROLE_ARN"                = local.grafana_iam_role
        "AWS_WEB_IDENTITY_TOKEN_FILE" = "/var/run/secrets/eks.amazonaws.com/serviceaccount/token"
        "AWS_REGION"                  = data.aws_region.current.name
      }
      extraSecretMounts = [
        { name      = "aws-iam-token"
          mountPath = "/var/run/secrets/eks.amazonaws.com/serviceaccount"
          readOnly  = true
          projected = {
            defaultMode = 420 #This is 644 in octal
            sources = [
              { serviceAccountToken = {
                audience          = "sts.amazonaws.com"
                expirationSeconds = 86400
                path              = "token"
                }
              },
            ]
          }
        }
      ]
      additionalDataSources = [
        { name     = "CloudWatch"
          type     = "cloudwatch"
          access   = "proxy"
          uid      = "cloudwatch"
          editable = false
          jsonData = {
            authType     = "default"
            efaultRegion = data.aws_region.current.name
          }
        }
      ]
    }
    prometheus = {
      ingress = {
        enabled  = true
        hosts    = [local.prometheus_host]
        pathType = "Prefix"
        annotations = merge(local.alb_ingress_annotations, {
          "alb.ingress.kubernetes.io/load-balancer-name" = "prometheus"
          "alb.ingress.kubernetes.io/auth-type"          = "oidc"
          "alb.ingress.kubernetes.io/auth-idp-oidc" = jsonencode(
            { issuer                = "https://${local.dex_host}"
              authorizationEndpoint = "https://${local.dex_host}/auth"
              tokenEndpoint         = "https://${local.dex_host}/token"
              userInfoEndpoint      = "https://${local.dex_host}/userinfo"
              secretName            = "govuk-dex-prometheus"
          })
          "alb.ingress.kubernetes.io/auth-on-unauthenticated-request" = "authenticate"
          "alb.ingress.kubernetes.io/auth-scope"                      = "email openid"
        })
      }
      # Match all PrometheusRules cluster-wide. (If an app/team needs a separate
      # Prom instance, it almost certainly needs a separate EKS cluster too.)
      prometheusSpec = {
        ruleNamespaceSelector = {
          matchExpressions = [{
            key      = "no_monitor"
            operator = "DoesNotExist"
            values   = []
          }]
        }
        # Allow empty ruleSelector (https://github.com/prometheus-community/helm-charts/blob/2cacc16807caedc6cabf1606db27e0d78c844564/charts/kube-prometheus-stack/templates/prometheus/prometheus.yaml#L202)
        ruleSelectorNilUsesHelmValues = false
        podMonitorNamespaceSelector = {
          matchExpressions = [{
            key      = "no_monitor"
            operator = "DoesNotExist"
            values   = []
          }]
        }
        podMonitorSelectorNilUsesHelmValues = false
      }
    }
  })]
}
