module "gatekeeper" {
  source = "./modules/gatekeeper"

  dryrun_map = {
    immutable_configmap                    = true
    validate_jobrequestreviews             = false
    jobrequestoperator_requiredannotations = false
    deny_default_namespace                 = false
  }

  constraint_violations_max_to_display = 25

  controller_mem_limit = var.gatekeeper_controller_resources.mem_limit
  controller_mem_req   = var.gatekeeper_controller_resources.mem_req
  audit_mem_limit      = var.gatekeeper_controller_resources.audit_mem_limit
  audit_mem_req        = var.gatekeeper_controller_resources.audit_mem_req

  depends_on = [helm_release.aws_lb_controller]
}
