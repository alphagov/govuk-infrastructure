#------------------------------------------------------------------------------
# Organisation
#------------------------------------------------------------------------------
variable "tfc_hostname" {
  type        = string
  default     = "app.terraform.io"
  description = "The hostname of the TFC or TFE to use with AWS"
}

variable "organization" {
  type        = string
  description = "Name of Organization to create Workspace in."
  default     = "govuk"
}

variable "token" {
  type        = string
  description = "Account token"
  sensitive   = true
}

#------------------------------------------------------------------------------
# Projects
#------------------------------------------------------------------------------
variable "project_names" {
  description = "List of project names"
  type        = list(string)
  default     = ["govuk-infrastructure"]
}

#------------------------------------------------------------------------------
# Workspace
#------------------------------------------------------------------------------

variable "workspace_name" {
  type        = string
  description = "Name of Workspace."
  default     = "Default Workspace"
}

variable "workspace_desc" {
  type        = string
  description = "Description of Workspace."
  default     = "Created by Terraform Workspacer module."
}

# variable "agent_pool_id" {
#   type        = string
#   description = "ID of existing Agent Pool to assign to Workspace. Only use if `execution_mode` is set to `agent`."
#   default     = null
# }

# variable "allow_destroy_plan" {
#   type        = bool
#   description = "Boolean setting to allow destroy plans on Workspace."
#   default     = true
# }

# variable "auto_apply" {
#   type        = bool
#   description = "Boolean to automatically run Terraform Apply when a Terraform Plan with changes is successful."
#   default     = false
# }

variable "execution_mode" {
  type        = string
  description = "Execution mode of Workspace. Valid values are `remote`, `local`, or `agent`."
  default     = "remote"

  validation {
    condition     = contains(["remote", "local", "agent"], var.execution_mode)
    error_message = "Valid values are `remote`, `local`, or `agent`."
  }
}

# variable "assessments_enabled" {
#   type        = bool
#   description = "Boolean to enable Health Assessments such as Drift Detection on Workspace."
#   default     = false
# }

# variable "file_triggers_enabled" {
#   type        = bool
#   description = "Boolean to filter Runs triggered via webhook (VCS push) based on `working_directory` and `trigger_prefixes`."
#   default     = true
# }

# variable "global_remote_state" {
#   type        = bool
#   description = "Boolean to allow all Workspaces within the Organization to remotely access the State of this Workspace."
#   default     = false
# }

# variable "remote_state_consumer_ids" {
#   type        = list(string)
#   description = "List of existing Workspace IDs allowed to remotely access the State of Workspace."
#   default     = null
# }

variable "queue_all_runs" {
  type        = bool
  description = "Boolean setting for Workspace to automatically queue all Runs after creation."
  default     = true
}

# variable "speculative_enabled" {
#   type        = bool
#   description = "Boolean to allow Speculative Plans on Workspace."
#   default     = true
# }

# variable "structured_run_output_enabled" {
#   type        = bool
#   description = "Boolean to enable the advanced Run UI. Set to `false` for the traditional console-based Run output."
#   default     = true
# }

# variable "ssh_key_id" {
#   type        = string
#   description = "SSH private key the Workspace will use for downloading Terraform modules from Git-based module sources. Key must exist in Organization first."
#   default     = null
# }

variable "workspace_tags" {
  type        = list(string)
  description = "List of tag names to apply to Workspace. Tags must only contain letters, numbers, or colons."
  default     = []
}

variable "terraform_version" {
  type        = string
  description = "Version constraint for Terraform for this workspace."
  default     = "~> 1.8.0"
}

# variable "trigger_prefixes" {
#   type        = list(string)
#   description = "List of paths relative to the root of the VCS repo to filter on when `file_triggers_enabled` is `true`."
#   default     = null
# }

variable "trigger_patterns" {
  type        = list(string)
  description = "List of glob patterns that describe the files monitored for changes to trigger Runs in Workspace. Mutually exclusive with `trigger_prefixes`. Only available with TFC."
  default     = null
}

variable "working_directory" {
  type        = string
  description = "The relative path that Terraform will execute within. Defaults to the root of the repo."
  default     = null
}

variable "vcs_repo" {
  type        = map(string)
  description = "Map of settings to connect Workspace to VCS repository."
  default     = {}
}

# variable "tags_regex" {
#   type        = string
#   description = "A regular expression used to trigger a Run in Workspace for matching Git tags. This option conflicts with `trigger_patterns` and `trigger_prefixes`. Should only set this value if the former is not being used."
#   default     = null
# }

# variable "force_delete" {
#   type        = bool
#   description = "Boolean to allow deletion of the Workspace if there is a Terraform state that contains resources."
#   default     = null
# }

variable "project_name" {
  type        = string
  description = "Name of existing Project to place Workspace in."
  default     = null
}

#------------------------------------------------------------------------------
# Workspace Variables
#------------------------------------------------------------------------------
variable "tfvars" {
  type        = any
  description = "Map of Terraform variables to add to Workspace."
  default     = {}
}

# variable "tfvars_sensitive" {
#   type        = any
#   description = "Map of sensitive Terraform variables to add to Workspace."
#   default     = {}
# }

# variable "tfvars_ignore_changes" {
#   type        = any
#   description = "Map of Terraform variables to add to Workspace whereby changes made outside of Terraform will be ignored."
#   default     = {}
# }

# variable "envvars" {
#   type        = map(string)
#   description = "Map of Environment variables to add to Workspace."
#   default     = {}
# }

# variable "envvars_sensitive" {
#   type        = map(string)
#   description = "Map of sensitive Environment variables to add to Workspace."
#   default     = {}
# }

# variable "envvars_ignore_changes" {
#   type        = map(string)
#   description = "Map of sensitive Environment variables to add to Workspace whereby changes made outside of Terraform will be ignored."
#   default     = {}
# }

# #------------------------------------------------------------------------------
# # Team Access
# #------------------------------------------------------------------------------
variable "team_access" {
  type        = map(string)
  description = "Map of existing Team(s) and built-in permissions to grant on Workspace."
  default     = {}
}

# variable "custom_team_access" {
#   type = map(
#     object(
#       {
#         runs              = string
#         variables         = string
#         state_versions    = string
#         sentinel_mocks    = string
#         workspace_locking = bool
#         run_tasks         = bool
#       }
#     )
#   )
#   description = "Map of existing Team(s) and custom permissions to grant on Workspace. If used, all keys in the object must be specified."
#   default     = {}
# }

# #------------------------------------------------------------------------------
# # Notifications
# #------------------------------------------------------------------------------
# variable "notifications" {
#   type = list(
#     object(
#       {
#         name             = string
#         destination_type = string
#         url              = optional(string)
#         token            = optional(string)
#         email_addresses  = optional(list(string))
#         email_user_ids   = optional(list(string))
#         triggers         = list(string)
#         enabled          = bool
#       }
#     )
#   )
#   description = "List of Notification objects to configure on Workspace."
#   default     = []
# }

# #------------------------------------------------------------------------------
# # Run Triggers
# #------------------------------------------------------------------------------
# variable "run_trigger_source_workspaces" {
#   type        = list(string)
#   description = "List of existing Workspace names that will trigger runs on Workspace."
#   default     = []
# }

# #------------------------------------------------------------------------------
# # Workspace Variable Sets
# #------------------------------------------------------------------------------
variable "variable_set_names" {
  type        = list(string)
  description = "List of names of existing Variable Sets to add this Workspace into."
  default     = []
}

# #------------------------------------------------------------------------------
# # Workspace Policy Sets
# #------------------------------------------------------------------------------
# variable "policy_set_names" {
#   type        = list(string)
#   description = "List of names of existing Policy Sets to add this Workspace into."
#   default     = []
# }
