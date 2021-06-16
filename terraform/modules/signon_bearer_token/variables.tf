# TODO: Create user for each workspace, use unique ID
variable "api_user_email" {
  type        = string
  description = "Workspace-aware email address for a Signon OAuth application resourcee, e.g. publisher@test.govuk.digital"
}

# TODO: We should acquire the unique ID for an application when we create it
# `app_name` should be replaced with `app_id`.
variable "app_name" {
  type        = string
  description = "Workspace-aware name for a Signon OAuth application resource, e.g. Publishing API"
}

variable "client_app" {
  type        = string
  description = "Hyphenated lowercase app name without variant E.g. content-store, publishing-api"
}

variable "deploy_event_bucket_arn" {
  type        = string
  description = "S3 bucket ARN used to trigger app redeployment following secret rotation"
}

variable "deploy_event_bucket_name" {
  type        = string
  description = "S3 bucket name used to trigger app redeployment following secret rotation"
}

variable "name" {
  type = string
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnets for VPC"
}

variable "signon_admin_password_arn" {
  type        = string
  description = "ARN of the SecretsManager Secret holding the Signon admin password for the cluster"
}

variable "signon_host" {
  type        = string
  description = "Workspace-aware public hostname for signon app e.g. signon.ecs.test.govuk.digital"
}

variable "signon_lambda_security_group_id" {
  type = string
}

variable "workspace" {
  type = string
}

variable "environment" {
  type = string
}

variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}
