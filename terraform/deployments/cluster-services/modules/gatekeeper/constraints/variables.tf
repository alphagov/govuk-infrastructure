variable "cluster_domain_name" {
  description = "The cluster domain used for externalDNS annotations and certmanager"
}

variable "integration_test_zone" {
  description = "Integration test zone, for test clusters to use it for valid ingress policy"
  default     = ""
}

variable "dryrun_map" {
  description = "run constraints in dryrun mode"
  type = object({
    service_type                       = bool
    snippet_allowlist                  = bool
    modsec_snippet_nginx_class         = bool
    modsec_nginx_class                 = bool
    ingress_clash                      = bool
    hostname_length                    = bool
    external_dns_identifier            = bool
    external_dns_weight                = bool
    valid_hostname                     = bool
    warn_service_account_secret_delete = bool
    user_ns_requires_psa_label         = bool
    deprecated_apis_1_26               = bool
    deprecated_apis_1_27               = bool
    deprecated_apis_1_29               = bool
    lock_priv_capabilities             = bool
    warn_kubectl_create_sa             = bool
    allow_duplicate_hostname_yaml      = bool
    block_ingresses                    = bool
    ingress_valid_classname            = bool
    ingress_internal_class_domain      = bool
    immutable_configmap                = bool
  })
}

