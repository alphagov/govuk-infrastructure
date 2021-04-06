# TODO: Create user for each workspace, use unique ID
variable "api_user_email" {
  type        = string
  description = "Workspace-aware email address for a Signon OAuth application resourcee, e.g. publisher@alphagov.co.uk"
}

# TODO: We should acquire the unique ID for an application when we create it
# `app_name` should be replaced with `app_id`.
variable "app_name" {
  type        = string
  description = "Workspace-aware name for a Signon OAuth application resource, e.g. Publishing API"
}

variable "from_app" {
  type = string
}

variable "signon_admin_password_arn" {
  type        = string
  description = "ARN of the SecretsManager Secret holding the Signon admin password for the cluster"
}

variable "signon_host" {
  type        = string
  description = "Workspace-aware public hostname for signon app e.g. signon.ecs.test.govuk.digital"
}

variable "to_app" {
  type = string
}

variable "workspace" {
  type = string
}
