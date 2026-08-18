variable "dryrun_map" {
  description = "run constraints in dryrun mode"
  type = object({
    block_default_namespace                = bool
    immutable_configmap                    = bool
    validate_jobrequestreviews             = bool
    jobrequestoperator_requiredannotations = bool
  })
}

