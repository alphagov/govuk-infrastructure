variable "apps_namespace" {
  type        = string
  description = "Name of the namespace to create for ArgoCD to deploy apps into by default."
  default     = "apps"
}

variable "argo_workflows_namespaces" {
  type        = list(string)
  description = "Namespaces in which Argo will run workflows."
  default     = ["apps"]
}

variable "argo_redis_ha" {
  type        = bool
  description = "Whether to run high-availability (3 replicas) Redis for ArgoCD, instead of 1 replica."
  default     = true
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

variable "dex_github_orgs_teams" {
  type        = list(object({ name = string, teams = list(string) }))
  description = "List of GitHub orgs and associated teams that Dex authorises. Format [{name='github_org', teams=['github_team_name']}] "
  default     = [{ name = "alphagov", teams = ["gov-uk-production-deploy"] }]
}

variable "default_desired_ha_replicas" {
  type        = number
  description = "Default number of desired replicas for high availability"
  default     = 3
}
