variable "puller_arns" {
  type        = list(string)
  description = "List of IAM principals who should be authorised to pull from this registry."
}

variable "emails" {
  type    = list(string)
  default = [] # TODO: Set emails in tfvars.

}

variable "govuk_environment" {
  type        = string
  description = "Acceptable values are test, integration, staging, production"
}

variable "env" {
  type        = string
  description = "Shorthand environment name acceptable values are test, intg, stag, prod"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
}
