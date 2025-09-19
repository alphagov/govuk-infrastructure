resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns"
  chart            = "external-dns"
  version          = "1.16.1"
  namespace        = local.services_ns
  create_namespace = true

  values = [yamlencode({
    provider = {
      name = "aws"
    }
    env = [
      {
        name  = "AWS_DEFAULT_REGION"
        value = "eu-west-1"
      }
    ]
    extraArgs = ["--aws-zone-type=public"]
    serviceAccount = {
      name = "external-dns"
      annotations = {
        "eks.amazonaws.com/role-arn" = data.terraform_remote_state.cluster_infrastructure.outputs.external_dns_role_arn
      }
    }
    automountServiceAccountToken = true
    revisionHistoryLimit         = 10
    txtOwnerId                   = "govuk"
    domainFilters = [
      data.terraform_remote_state.cluster_infrastructure.outputs.external_dns_zone_name
    ]
    interval           = "5m"
    triggerLoopOnEvent = true
  })]
}
