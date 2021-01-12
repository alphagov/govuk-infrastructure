output "private_subnets" {
  value = data.terraform_remote_state.infra_networking.outputs.private_subnet_ids
}

output "publisher-web_security_groups" {
  value = module.govuk.publisher_security_groups
}

output "frontend_security_groups" {
  value = module.govuk.frontend_security_groups
}

output "signon_security_groups" {
  value = module.govuk.signon_security_groups
}

output "content-store_security_groups" {
  value = module.govuk.content_store_security_groups
}

output "draft-content-store_security_groups" {
  value = module.govuk.draft_content_store_security_groups
}

output "log_group" {
  value = "govuk" # TODO make this workspace aware
}

output "mesh_name" {
  value = var.mesh_name
}

output "mesh_domain" {
  value = var.mesh_domain
}

output "app_domain" {
  value = var.public_lb_domain_name
}

output "app_domain_internal" {
  value = var.internal_domain_name
}

output "govuk_website_root" {
  value = "https://frontend.${var.public_lb_domain_name}" # TODO: Change back to www once router is up
}

output "fargate_execution_iam_role_arn" {
  value = module.govuk.fargate_execution_iam_role_arn
}

output "fargate_task_iam_role_arn" {
  value = module.govuk.fargate_task_iam_role_arn
}

output "redis_host" {
  value = module.govuk.redis_host
}

output "redis_port" {
  value = module.govuk.redis_port
}
