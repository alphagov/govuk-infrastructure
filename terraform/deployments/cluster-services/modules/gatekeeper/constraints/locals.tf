locals {
  constraint_path          = "${path.module}/../resources/constraints"
  immutable_configmap_yaml = yamldecode(file("${local.constraint_path}/immutable_configmap.yaml"))

  # For each constraint, a value needs to be in the constraint map. This bloc allows us to set values on constraints which enables us to toggle the configuration of the constraints. -- we merge in the spec separately to avoid overwriting entire spec key
  constraint_map = {
    immutable_configmap = merge(local.immutable_configmap_yaml, { "spec" : merge(local.immutable_configmap_yaml, { "enforcementAction" : var.dryrun_map.immutable_configmap ? "dryrun" : "deny" }) })
  }
}
