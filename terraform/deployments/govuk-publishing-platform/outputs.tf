output "private_subnets" {
  value = data.terraform_remote_state.infra_networking.outputs.private_subnet_ids
}

output "publisher-web_security_groups" {
  value       = module.publisher.security_groups
  description = "Used by ECS RunTask to run short-lived tasks with the same SG permissions as the publisher ECS Service."
}

output "frontend_security_groups" {
  value       = module.frontend.security_groups
  description = "Used by ECS RunTask to run short-lived tasks with the same SG permissions as the frontend ECS Service."
}

output "signon_security_groups" {
  value       = module.signon.security_groups
  description = "Used by ECS RunTask to run short-lived tasks with the same SG permissions as the signon ECS Service."
}

output "content-store_security_groups" {
  value       = module.content_store.security_groups
  description = "Used by ECS RunTask to run short-lived tasks with the same SG permissions as the content-store ECS Service."
}

output "draft-content-store_security_groups" {
  value       = module.draft_content_store.security_groups
  description = "Used by ECS RunTask to run short-lived tasks with the same SG permissions as the draft-content-store ECS Service."
}

output "smokey_security_groups" {
  value       = [aws_security_group.smokey.id]
  description = "Used by ECS RunTask to run smokey"
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
  value = aws_iam_role.execution.arn
}

output "fargate_task_iam_role_arn" {
  value = aws_iam_role.task.arn
}

output "redis_host" {
  value = module.shared_redis_cluster.redis_host
}

output "redis_port" {
  value = module.shared_redis_cluster.redis_port
}
