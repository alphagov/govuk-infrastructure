resource "helm_release" "concourse" {
  repository       = "https://concourse-charts.storage.googleapis.com/"
  chart            = "concourse"
  name             = "concourse"
  create_namespace = true
  timeout          = 1200

  values = [yamlencode({
    secrets = {
      localUsers = "concourse:bootstrap",
    },
    rbas = {
      workerServiceAccountAnnotations = {
        "eks.amazonaws.com/role-arn" = module.concourse_worker_iam_role.iam_role_arn
      }
    },
    web = {
      ingress = {
        ingressClassName = "aws-lb"
        hosts            = ["concourse.${data.terraform_remote_state.cluster_infrastructure.outputs.external_dns_zone_name}"]
        annotations = {
          "alb.ingress.kubernetes.io/scheme"             = "internet-facing"
          "alb.ingress.kubernetes.io/listen-ports"       = "[{\"HTTPS\":443}]"
          "alb.ingress.kubernetes.io/load-balancer-name" = "${var.govuk_environment}-concourse-web"
        }
        tls = [
          {
            hosts = ["concourse.${data.terraform_remote_state.cluster_infrastructure.outputs.external_dns_zone_name}"]
          }
        ]
      }
    }
  })]
}

module "concourse_worker_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.5"

  role_name        = "${var.govuk_environment}-concourse-worker-${data.terraform_remote_state.cluster_infrastructure.outputs.cluster_id}"
  role_description = "Role for Concourse workers in the Kubernetes cluster"
  role_policy_arns = {
    # Under no circumstances should this ever make its way
    # into the main branch.
    #
    # It's being used during a firebreak experiment to expedite
    # things, and to not have to fight with permissions for now.
    "admin" = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  oidc_providers = {
    main = {
      provider_arn               = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_oidc_provider_arn
      namespace_service_accounts = ["concourse-main:concourse-worker"]
    }
  }
}


output "concourse_web_url" {
  value = "https://concourse.${data.terraform_remote_state.cluster_infrastructure.outputs.external_dns_zone_name}"
}


