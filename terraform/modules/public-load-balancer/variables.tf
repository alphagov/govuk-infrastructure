variable "app_domain" {
  type        = string
  description = "e.g. test.publishing.service.gov.uk"
}

variable "app_name" {
  type        = string
  description = "A GOV.UK application name. E.g. publisher, content-publisher"
}

variable "workspace_suffix" {
  type    = string
  default = "govuk" # TODO: Is this the default value?
}

variable "dns_a_record_name" {
  type        = string
  description = "DNS A Record name. Should be cluster and environment-aware."
}

variable "public_subnets" {
  type = list
}

# TODO: Is this the right terminology?
variable "public_lb_domain_name" {
  type        = string
  description = "Domain in which to create DNS records for the app's Internet-facing load balancer. For example, staging.govuk.digital"
}

variable "service_security_group_id" {
  type        = string
  description = "Security group ID for the associated ECS Service."
}

variable "vpc_id" {
  type = string
}

variable "health_check_path" {
  type    = string
  default = "/healthcheck"
}

variable "target_port" {
  type    = number
  default = 80
}

variable "external_cidrs_list" {
  type    = list
  default = ["0.0.0.0/0"]
}
