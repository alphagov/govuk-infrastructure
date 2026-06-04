module "gatekeeper" {
  source = "github.com/alphagov/govuk-terraform-gatekeeper?ref=0.0.1"

  dryrun_map = {
    service_type                       = true,
    snippet_allowlist                  = true,
    modsec_snippet_nginx_class         = true,
    modsec_nginx_class                 = true,
    ingress_clash                      = true,
    hostname_length                    = true,
    external_dns_identifier            = true,
    external_dns_weight                = true,
    valid_hostname                     = true
    warn_service_account_secret_delete = true,
    user_ns_requires_psa_label         = true,
    deprecated_apis_1_26               = true,
    deprecated_apis_1_27               = true,
    deprecated_apis_1_29               = true,
    warn_kubectl_create_sa             = true,
    # There are violations on system namespaces and until that is cleared, this
    # constraint will be in dryrun mode
    lock_priv_capabilities        = true,
    allow_duplicate_hostname_yaml = true,
    block_ingresses               = true,
    ingress_valid_classname       = true,
    ingress_internal_class_domain = true,
  }

  is_production                        = false
  environment_name                     = "eph-jas-0300626"
  out_of_hours_alert                   = "false"
  cluster_domain_name                  = local.external_dns_zone_name
  cluster_color                        = terraform.workspace == "production" ? "green" : "black"
  constraint_violations_max_to_display = 25

  controller_mem_limit = terraform.workspace == "production" ? "8Gi" : "1Gi"
  controller_mem_req   = terraform.workspace == "production" ? "4Gi" : "512Mi"
  audit_mem_limit      = terraform.workspace == "production" ? "16Gi" : "1Gi"
  audit_mem_req        = terraform.workspace == "production" ? "4Gi" : "512Mi"
}
