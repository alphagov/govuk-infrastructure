variable "apps_namespace" {
  type        = string
  description = "Name of the namespace to create for ArgoCD to deploy apps into by default."
  default     = "apps"
}

variable "licensify_namespace" {
  type        = string
  description = "Name of the namespace to create for ArgoCD to deploy licensify apps into by default."
  default     = "licensify"
}

variable "datagovuk_namespace" {
  type        = string
  description = "Name of the namespace to create for ArgoCD to deploy DGU apps into by default."
  default     = "datagovuk"
}

variable "argo_workflows_namespaces" {
  type        = list(string)
  description = "Namespaces in which Argo will run workflows."
  default     = ["apps"]
}

variable "github_read_write_team" {
  type        = string
  description = "Name of the GitHub team that should have read-write access to Dex SSO-enabled applications"
  default     = "alphagov:gov-uk-production-deploy"
}

variable "github_read_only_team" {
  type        = string
  description = "Name of the GitHub team that should have read-only access to Dex SSO-enabled applications"
  default     = "alphagov:gov-uk"
}

variable "github_ithc_team" {
  type        = string
  description = "Name of the GitHub team for ITHC testers to have read-only access to Dex SSO-enabled applications"
  default     = "alphagov:gov-uk-ithc-and-penetration-testing"
}

variable "helm_timeout_seconds" {
  type        = number
  description = "Timeout for helm install/upgrade operations."
  default     = "1200"
}

variable "govuk_aws_state_bucket" {
  type        = string
  description = "Name of the S3 bucket used for govuk-aws's Terraform state."
}

variable "govuk_environment" {
  type        = string
  description = "Acceptable values are test, integration, staging, production"
}

variable "dex_github_orgs_teams" {
  type        = list(object({ name = string, teams = list(string) }))
  description = "List of GitHub orgs and associated teams that Dex authorises. Format [{name='github_org', teams=['github_team_name']}] "
  default     = [{ name = "alphagov", teams = ["gov-uk-production-deploy"] }]
}

variable "desired_ha_replicas" {
  type        = number
  description = "Default number of desired replicas for high availability"
  default     = 3
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster to create resources in"
  default     = "govuk"
}

variable "force_destroy" {
  type        = bool
  description = "Setting for force_destroy on resources such as Route53 zones. For use in non-production environments to allow for automated tear-down."
  default     = false
}
