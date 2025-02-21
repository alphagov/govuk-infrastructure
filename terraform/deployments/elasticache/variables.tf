variable "govuk_environment" {
  type        = string
  description = "GOV.UK environment name"
}

variable "instances" {
  type        = map(any)
  description = "Map of instance name -> settings"
}
