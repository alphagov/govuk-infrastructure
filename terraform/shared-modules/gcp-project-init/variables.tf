variable "project_id" {
  description = "The GCP project ID to manage."
  type        = string
}

variable "project_name" {
  description = "The name of the GCP project."
  type        = string
}

variable "billing_account" {
  description = "The default billing account ID to associate with the project."
  type        = string
  default     = "015C7A-FAF970-B0D375"
}

variable "folder_id" {
  description = "The Folder ID to create the project under."
  type        = string
  default     = "278098142879"
}

variable "terraform_service_account" {
  description = "The Terraform service account email to be hard-coded as an owner."
  type        = string
  default     = "serviceAccount:terraform-cloud-production@govuk-production.iam.gserviceaccount.com"
}

variable "project_owners" {
  description = "A list of IAM members (users, groups, or SAs) to be granted roles/owner."
  type        = list(string)
  default     = []
}

variable "project_editors" {
  description = "A list of IAM members (users, groups, or SAs) to be granted roles/editor."
  type        = list(string)
  default     = []
}

variable "project_viewers" {
  description = "A list of IAM members (users, groups, or SAs) to be granted roles/viewer."
  type        = list(string)
  default     = []
}
