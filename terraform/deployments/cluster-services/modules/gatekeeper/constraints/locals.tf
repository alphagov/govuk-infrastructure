locals {
  constraint_path                        = "${path.module}/../resources/constraints"
  immutable_configmap_yaml               = yamldecode(file("${local.constraint_path}/immutable_configmap.yaml"))
  validate_jobrequestreviews             = yamldecode(file("${local.constraint_path}/validate_jobrequestreviews.yaml"))
  jobrequestoperator_requiredannotations = yamldecode(file("${local.constraint_path}/jobrequestoperator_requiredannotations.yaml"))
  deny_default_namespace_yaml            = yamldecode(file("${local.constraint_path}/deny_default_namespace.yaml"))

  # For each constraint, a value needs to be in the constraint map. This bloc allows us to set values on constraints which enables us to toggle the configuration of the constraints. -- we merge in the spec separately to avoid overwriting entire spec key
  constraint_map = {
    immutable_configmap                    = merge(local.immutable_configmap_yaml, { "spec" : merge(local.immutable_configmap_yaml, { "enforcementAction" : var.dryrun_map.immutable_configmap ? "dryrun" : "deny" }) })
    validate_jobrequestreviews             = merge(local.validate_jobrequestreviews, { "spec" : merge(local.validate_jobrequestreviews, { "enforcementAction" : var.dryrun_map.validate_jobrequestreviews ? "dryrun" : "deny" }) })
    jobrequestoperator_requiredannotations = merge(local.jobrequestoperator_requiredannotations, { "spec" : merge(local.jobrequestoperator_requiredannotations, { "enforcementAction" : var.dryrun_map.jobrequestoperator_requiredannotations ? "dryrun" : "deny" }) })
    deny_default_namespace                 = merge(local.deny_default_namespace_yaml, { "spec" : merge(local.deny_default_namespace_yaml.spec, { "enforcementAction" : var.dryrun_map.deny_default_namespace ? "dryrun" : "deny" }) })
  }
}
