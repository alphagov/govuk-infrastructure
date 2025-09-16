locals {
  services_ns          = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_services_namespace
  is_ephemeral         = startswith(var.govuk_environment, "eph-")
  helm_timeout_seconds = 15 * 60
}
