variable "constraint_violations_max_to_display" {
  description = "the max number of violations to display per constraint"
  default     = 20
  type        = number
}

variable "controller_mem_limit" {
  description = "memory limit for the gatekeeper controller manager"
  type        = string
}

variable "controller_mem_req" {
  description = "memory request for gatekeeper controller manager"
  type        = string
}

variable "audit_mem_limit" {
  description = "memory limit for gatekeeper audit"
  type        = string
}

variable "audit_mem_req" {
  description = "memory req for gatekeeper audit"
  type        = string
}

variable "dryrun_map" {
  description = "run constraints in dryrun mode"
  type = object({
    immutable_configmap                    = bool
    validate_jobrequestreviews             = bool
    jobrequestoperator_requiredannotations = bool
    deny_default_namespace                 = bool
  })
}

