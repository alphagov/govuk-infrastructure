variable "internal_domain_name" {
  description = "The internal root root domain name"
  type        = string
  default     = "test.govuk-internal.digital"
}

variable "service_name" {
  description = "Service name of the Fargate service, cluster, task etc."
  type        = string
  default     = "statsd"
}

variable "private_subnets" {
  description = "The subnet ids for govuk_private_a, govuk_private_b, and govuk_private_c"
  type        = list
  default     = ["subnet-6dc4370b", "subnet-463bfd0e", "subnet-bfecd0e4"]
}

variable "govuk_management_access_security_group" {
  description = "Group used to allow access by management systems"
  type        = string
  default     = "sg-0b873470482f6232d"
}
