module "gatekeeper" {
  source = "./modules/gatekeeper"

  dryrun_map = {
    immutable_configmap = true
  }

  is_production                        = terraform.workspace == "production"
  environment_name                     = var.govuk_environment
  constraint_violations_max_to_display = 25

  controller_mem_limit = terraform.workspace == "production" ? "8Gi" : "1Gi"
  controller_mem_req   = terraform.workspace == "production" ? "4Gi" : "512Mi"
  audit_mem_limit      = terraform.workspace == "production" ? "16Gi" : "1Gi"
  audit_mem_req        = terraform.workspace == "production" ? "4Gi" : "512Mi"

  depends_on = [helm_release.aws_lb_controller]
}
