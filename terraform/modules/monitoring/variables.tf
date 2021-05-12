variable "external_app_domain" {
  description = "Domain in which to create DNS records for the app's Internet-facing load balancer. For example, staging.govuk.digital"
  type        = string
}

variable "capacity_provider" {
  description = "Set this to FARGATE_SPOT to use spot instances in the ECS cluster by default. If unset, the cluster will use on-demand (regular) instances by default. Tasks can still override the default capacity provider in either case."
  type        = string
  default     = "FARGATE"
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  description = "Subnet IDs to use for non-Internet-facing resources."
  type        = list(any)
}

variable "public_subnets" {
  description = "Subnet IDs to use for Internet-facing resources."
  type        = list(any)
}

variable "publishing_service_domain" {
  type        = string
  description = "e.g. test.publishing.service.gov.uk"
}

variable "govuk_management_access_sg_id" {
  description = "ID of security group (from the govuk-aws repo) for access from jumpboxes etc. This SG is added to all ECS instances."
  type        = string
}

variable "grafana_desired_count" {
  description = "Desired count of Grafana instances"
  type        = number
  default     = 1
}

variable "grafana_cidrs_allow_list" {
  description = "List of CIDRs that can access Grafana"
  type        = list(any)
}

variable "splunk_url_secret_arn" {
  type        = string
  description = "ARN to the secret containing the URL for the Splunk instance (of the form `https://http-inputs-XXXXXXXX.splunkcloud.com:PORT`)."
}

variable "splunk_token_secret_arn" {
  type        = string
  description = "ARN to the secret containing the HTTP Event Collector (HEC) token."
}

variable "splunk_index" {
  type        = string
  description = "Splunk index to log events to (which HEC token must have access to write to)."
}

variable "splunk_sourcetype" {
  type        = string
  default     = null
  description = "The source type of the logs being sent to Splunk i.e. `log4j`."
}

variable "govuk_environment" {
  type = string
}

variable "workspace" {
  type = string
}

variable "additional_tags" {
  type = map(any)
}

variable "grafana_cpu" {
  type    = number
  default = 512
}

variable "grafana_memory" {
  type    = number
  default = 1024
}

variable "grafana_port" {
  type    = number
  default = 3000 # If we set this number to 80, there is a binding permission error, see: https://grafana.com/docs/grafana/latest/administration/configuration/#http_port
}

variable "grafana_registry" {
  type    = string
  default = "grafana"
}

variable "grafana_image_name" {
  type    = string
  default = "grafana"
}

variable "grafana_image_tag" {
  type    = string
  default = "latest"
}

variable "dns_public_zone_id" {
  type = string
}

variable "certificate_arn" {
  type = string
}
