# external_dns.tf manages the in-cluster components of the external-dns addon.
#
# The AWS resources (IAM policy, Route53 zone) for external-dns are in
# ../cluster-infrastructure/external_dns.tf.

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "5.4.4" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace  = local.services_ns
  values = [yamlencode({
    aws = {
      region   = data.aws_region.current.name
      zoneType = "public"
    }
    serviceAccount = {
      name = data.terraform_remote_state.cluster_infrastructure.outputs.external_dns_service_account_name
      annotations = {
        "eks.amazonaws.com/role-arn" = data.terraform_remote_state.cluster_infrastructure.outputs.external_dns_role_arn
      }
    }
    txtOwnerId    = data.terraform_remote_state.cluster_infrastructure.outputs.external_dns_zone_id
    domainFilters = [data.terraform_remote_state.cluster_infrastructure.outputs.external_dns_zone_name]
    # TODO: hook up Prometheus metrics (metrics.enabled, metrics.podAnnotations etc.)
  })]
}
