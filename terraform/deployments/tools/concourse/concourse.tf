resource "helm_release" "concourse" {
  name             = "concourse"
  repository       = "https://concourse-charts.storage.googleapis.com"
  chart            = "concourse"
  version          = "20.3.3"
  namespace        = "concourse"
  create_namespace = true
  # timeout          = var.helm_timeout_seconds
  values = [yamlencode({
    web = {
      ingress = {
        enabled = true
        annotations = {
          "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\":80},{\"HTTPS\":443}]"
          "alb.ingress.kubernetes.io/scheme" = "internet-facing"
          "alb.ingress.kubernetes.io/ssl-policy" = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
          "alb.ingress.kubernetes.io/ssl-redirect" = "443"
          "alb.ingress.kubernetes.io/target-type" = "ip"
        }
        hosts = [
          "concourse.tools.govuk.digital"
        ]
      }

      env = [
        {
          valueFrom = {
            secretKeyRef = {
              name = kubernetes_secret_v1.concourse_local_user_password.metadata[0].name
              key = "value"
            }
          }
          name = "CONCOURSE_ADD_LOCAL_USER"
        }
      ]
    }
  })]
}

resource "kubernetes_secret_v1" "concourse_local_user_password" {

  metadata {
    name = "concourse-web-user"
  }
  data = {
    value = "admin:${random_password.concourse_local_user_password.result}"
  }
}

resource "random_password" "concourse_local_user_password" {
  length  = 20
  special = false
}
