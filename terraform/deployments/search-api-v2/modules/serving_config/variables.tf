variable "id" {
  description = "The ID of the serving config (becomes part of the name after creation)"
  type        = string
}

variable "display_name" {
  description = "A human readable name for the serving config"
  type        = string
}

variable "engine_id" {
  description = "The name of the engine the serving control is created on"
  type        = string
}

variable "boost_control_ids" {
  description = "The IDs of the boost controls to attach to the serving config"
  type        = list(string)
  default     = []
}

variable "filter_control_ids" {
  description = "The IDs of the filter controls to attach to the serving config"
  type        = list(string)
  default     = []
}

variable "synonyms_control_ids" {
  description = "The IDs of the synonym controls to attach to the serving config"
  type        = list(string)
  default     = []
}
