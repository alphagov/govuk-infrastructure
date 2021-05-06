variable "external_app_domain" {
  description = "Domain in which to create DNS records for the app's Internet-facing load balancer. For example, staging.govuk.digital"
  type        = string
}

variable "ecs_default_capacity_provider" {
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

variable "desired_count" {
  description = "Desired count of Application instances"
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

variable "environment" {
  type = string
}
