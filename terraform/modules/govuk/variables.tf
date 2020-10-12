variable "vpc_id" {
  type = string
}

variable "govuk_app_domain_external" {
  type = string
}

variable "govuk_app_domain_internal" {
  type = string
}

variable "govuk_website_root" {
  type = string
}

variable "private_subnets" {
  description = "Subnet IDs to use for non-Internet-facing resources."
  type        = list
}

variable "public_subnets" {
  description = "Subnet IDs to use for Internet-facing resources."
  type        = list
}

variable "public_lb_domain_name" {
  description = "Domain in which to create DNS records for Internet-facing load balancers. For example, staging.govuk.digital"
  type        = string
}


# TODO: find out how asset_host is actually used and add a description to disambiguate it.
variable "asset_host" {
  type = string
}

variable "govuk_management_access_sg_id" {
  description = "ID of security group (defined outside this Terraform repo) for access from jumpboxes etc. This SG is added to all ECS instances."
  type        = string
}

variable "mongodb_host" {
  type = string
}

variable "redis_host" {
  description = "Hostname for the shared Redis (defined outside this Terraform repo)."
  type        = string
}

variable "redis_port" {
  description = "Port of the shared Redis"
  type        = number
  default     = 6379
}

variable "redis_security_group_id" {
  description = "ID of security group for the shared Redis (defined outside this Terraform repo)."
  type        = string
}

variable "statsd_host" {
  type = string
}

variable "documentdb_security_group_id" {
  description = "ID of security group for the shared DocumentDB (which isn't managed by this Terraform repo, at least initially)."
  type        = string
}

# TODO: pull common vars up from the app modules into here so that they can vary by environment.
