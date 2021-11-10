variable "argo_workflow_namespaces" {
  type        = list(string)
  description = "Namespaces in which Argo will run workflows."
}
variable "govuk_aws_state_bucket" {
  type        = string
  description = "Name of the S3 bucket used for govuk-aws's Terraform state."
}

variable "cluster_infrastructure_state_bucket" {
  type        = string
  description = "Name of the S3 bucket for the cluster-infrastructure module's Terraform state. Must match the name of the bucket specified in the backend config file."
}

variable "govuk_environment" {
  type        = string
  description = "Acceptable values are test, integration, staging, production"
}
