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

    force_destroy = true

    govuk_aws_state_bucket    = ""
    publishing_service_domain = "${var.ephemeral_cluster_id}.publishing.service.gov.uk"

    enable_arm_workers         = true
    enable_main_workers        = false
    enable_x86_workers         = false
    arm_workers_instance_types = ["m7g.2xlarge"]

    backup_retention_period = 0
    skip_final_snapshot     = true
    multi_az                = true

    databases = {
      ckan = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family         = "postgres13"
        name                         = "ckan"
        allocated_storage            = 1000
        instance_class               = "db.m6g.large"
        performance_insights_enabled = true
        project                      = "GOV.UK - DGU"
      }
    }
  }
}

module "vpc" {
  source = "./ws"

  name                 = "vpc"
  ephemeral_cluster_id = var.ephemeral_cluster_id
  variable_set_id      = module.var_set.id

  depends_on = [tfe_project.project]
}

module "cluster_infrastructure" {
  source = "./ws"

  name                 = "cluster-infrastructure"
  ephemeral_cluster_id = var.ephemeral_cluster_id
  variable_set_id      = module.var_set.id

  depends_on = [module.vpc, tfe_project.project]
}

module "cluster_services" {
  source = "./ws"

  name                 = "cluster-services"
  ephemeral_cluster_id = var.ephemeral_cluster_id
  variable_set_id      = module.var_set.id

  depends_on = [module.cluster_infrastructure, tfe_project.project]
}

module "rds" {
  source               = "./ws"
  name                 = "rds"
  ephemeral_cluster_id = var.ephemeral_cluster_id
  variable_set_id      = module.var_set.id

  depends_on = [module.vpc, tfe_project.project]
}

module "datagovuk_infrastructure" {
  source = "./ws"

  name                 = "datagovuk-infrastructure"
  ephemeral_cluster_id = var.ephemeral_cluster_id
  variable_set_id      = module.var_set.id

  depends_on = [module.cluster_services, module.rds, tfe_project.project]
}


