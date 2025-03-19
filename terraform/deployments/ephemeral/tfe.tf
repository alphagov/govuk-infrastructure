resource "tfe_project" "project" {
  organization = "govuk"
  name         = var.ephemeral_cluster_id
}

module "var_set" {
  source = "../tfc-configuration/variable-set"

  name     = var.ephemeral_cluster_id
  priority = true

  tfvars = {
    govuk_environment      = var.ephemeral_cluster_id
    cluster_name           = var.ephemeral_cluster_id
    external_dns_subdomain = var.ephemeral_cluster_id

    govuk_aws_state_bucket    = ""
    publishing_service_domain = "${var.ephemeral_cluster_id}.publishing.service.gov.uk"
    authentication_mode       = "API_AND_CONFIG_MAP"

    enable_arm_workers  = true
    enable_main_workers = false
    enable_x86_workers  = false
  }
}

module "cluster_infrastructure" {
  source = "./ws"

  name                 = "cluster-infrastructure"
  ephemeral_cluster_id = var.ephemeral_cluster_id
  variable_set_id      = module.var_set.id

  depends_on = [tfe_project.project]
}

module "cluster_services" {
  source = "./ws"

  name                 = "cluster-services"
  ephemeral_cluster_id = var.ephemeral_cluster_id
  variable_set_id      = module.var_set.id

  depends_on = [module.cluster_infrastructure, tfe_project.project]
}

module "datagovuk_infrastructure" {
  source = "./ws"

  name                 = "datagovuk-infrastructure"
  ephemeral_cluster_id = var.ephemeral_cluster_id
  variable_set_id      = module.var_set.id

  depends_on = [module.cluster_services, tfe_project.project]
}
