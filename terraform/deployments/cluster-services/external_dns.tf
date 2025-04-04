resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns"
  chart            = "external-dns"
  version          = "1.16.0"
  namespace        = local.services_ns
  create_namespace = true

  values = [yamlencode({
    provider = "aws"
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
        "eks.amazonaws.com/role-arn" = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.external_dns_role_arn
      }
    }
    automountServiceAccountToken = true
    revisionHistoryLimit         = 10
    txtOwnerId                   = "govuk"
    domainFilters = [
      data.tfe_outputs.cluster_infrastructure.nonsensitive_values.external_dns_zone_name
    ]
    interval           = "5m"
    triggerLoopOnEvent = true
  })]
}
