variable "github_app_id" {
  type        = string
  description = "The id of the GitHub App used for authentication."
}

variable "github_app_installation_id" {
  type        = string
  description = "The id of the installation of the GitHub App used for authentication."
}

variable "github_app_pem_file" {
  type        = string
  description = "The private key to sign access token requests."
}

