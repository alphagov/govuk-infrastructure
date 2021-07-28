# TODO: This is a placeholder service that will be replaced by `router` service.
# The service will still be deployed later by using `kubectl` or `helm`.
# The k8s ingress needs the service(s) to be present before creation or else
# it will stuck in creation.
# It is easier to have k8s ingress created in terraform since we can add a CNAME
# to the "random" FQDN of the AWS ALB created to represent the k8s ingress.


resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend"
  }
  spec {
    selector = {
      app = "frontend"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}


resource "kubernetes_ingress" "www_origin_ingress" {
  metadata {
    name = "www-origin-ingress"
    annotations = {
      "kubernetes.io/ingress.class" : "alb"
      "alb.ingress.kubernetes.io/scheme" : "internet-facing"
      "alb.ingress.kubernetes.io/subnets" : join(",", data.terraform_remote_state.infra_networking.outputs.public_subnet_ids)
      "alb.ingress.kubernetes.io/listen-ports" : "[{\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/certificate-arn" : aws_acm_certificate_validation.public.certificate_arn
    }
  }

  spec {
    backend {
      service_name = kubernetes_service.frontend.metadata.0.name
      service_port = 80
    }

    rule {
      http {
        path {
          backend {
            service_name = kubernetes_service.frontend.metadata.0.name
            service_port = 80
          }

          path = "/*"
        }
      }
    }

  }

  wait_for_load_balancer = true

  depends_on = [helm_release.aws_alb_controller]
}

resource "aws_route53_record" "www_origin" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "www-origin"
  type    = "CNAME"
  ttl     = 300
  records = [kubernetes_ingress.www_origin_ingress.status.0.load_balancer.0.ingress.0.hostname]
}

output "www_ingress_fqdn" {
  value = "${aws_route53_record.www_origin.name}.${aws_route53_zone.public.name}"
}
