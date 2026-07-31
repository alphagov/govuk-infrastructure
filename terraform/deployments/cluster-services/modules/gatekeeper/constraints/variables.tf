variable "dryrun_map" {
  description = "run constraints in dryrun mode"
  type = object({
    immutable_configmap = bool
  })
}

