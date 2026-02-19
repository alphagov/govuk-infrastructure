variable "govuk_environment" {
  type        = string
  description = "Acceptable values are test, integration, staging, production"
}

variable "provider_arn" {
  type        = string
  description = "Arn for the cluster oidc provier"
}

variable "cluster_id" {
  type        = string
  description = "For prefixing IRSA role name"
}

variable "account_id" {
  type        = string
  description = "AWS account id useful for constructing arns in policies"
}
