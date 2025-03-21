variable "id" {
  description = "The ID of the control (becomes part of the name after creation)"
  type        = string
}

variable "display_name" {
  description = "A human readable name for the control"
  type        = string
}

variable "engine_id" {
  description = "The name of the engine the control is created on"
  type        = string
}

variable "action" {
  description = "The action for the control (merged into the control properties)"
  type        = any
}

variable "conditions" {
  description = "The conditions for the control (merged into the control properties)"
  type        = list(any)
  default     = []
}
