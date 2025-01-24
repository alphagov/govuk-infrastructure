#
# Organisation
#

variable "tfc_hostname" {
  type        = string
  default     = "app.terraform.io"
  description = "The hostname of the TFC or TFE to use with AWS"
}

variable "organization" {
  type        = string
  description = "Name of TFC Organization that the workspace will belong to."
  default     = "govuk"
}

variable "token" {
  type        = string
  description = "Account token"
  sensitive   = true
}

#
# Projects
#

variable "project_names" {
  description = "List of project names"
  type        = list(string)
  default     = ["govuk-infrastructure"]
}

#
# Workspace
#

variable "workspace_name" {
  type    = string
  default = "Default Workspace"
}

variable "workspace_desc" {
  type    = string
  default = ""
}

variable "execution_mode" {
  type        = string
  description = "Valid values are `remote`, `local`, or `agent`."
  default     = "remote"

  validation {
    condition     = contains(["remote", "local", "agent"], var.execution_mode)
    error_message = "Valid values are `remote`, `local`, or `agent`."
  }
}

variable "queue_all_runs" {
  type        = bool
  description = "Whether the workspace should start automatically performing runs immediately after its creation."
  default     = true
}

variable "workspace_tags" {
  type        = list(string)
  description = "List of tag names to apply to the workspace. Tags must only contain letters, numbers, or colons."
  default     = []
}

variable "terraform_version" {
  type        = string
  description = "Version constraint for Terraform for this workspace."
  default     = "~> 1.10.5"
}

variable "trigger_patterns" {
  type        = list(string)
  description = "List of glob patterns that describe the files monitored for changes to trigger Runs in the workspace. Mutually exclusive with `trigger_prefixes`. Only available with TFC."
  default     = null
}

variable "working_directory" {
  type        = string
  description = "The relative path that Terraform will execute within. Defaults to the root of the repo."
  default     = null
}

variable "vcs_repo" {
  type        = map(string)
  description = "Map of settings to connect the workspace to a VCS repository."
  default     = {}
}

variable "project_name" {
  type        = string
  description = "Name of existing TFC project that the workspace will belong to."
  default     = null
}

#
# Workspace variables
#

variable "tfvars" {
  type        = any
  description = "Map of Terraform variables to add to the workspace."
  default     = {}
}

#
# Team access
#

variable "team_access" {
  type        = map(string)
  description = "Map of existing Team(s) and built-in permissions to grant on the workspace."
  default     = {}
}

#
# Workspace variable sets
#

variable "variable_set_names" {
  type        = list(string)
  description = "List of names of existing Variable Sets to add to the workspace."
  default     = []
}
