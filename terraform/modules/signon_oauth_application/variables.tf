variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

variable "app_name" {
  type        = string
  description = "Name for a Signon OAuth application resource, e.g. publishing_api"
}

variable "app_shortname" {
  type = string
}

variable "description" {
  type = string
}

variable "environment" {
  type = string
}

variable "home_uri" {
  type = string
}

variable "permissions" {
  type = list(string)
}

variable "redirect_path" {
  type = string
}

variable "workspace" {
  type = string
}
