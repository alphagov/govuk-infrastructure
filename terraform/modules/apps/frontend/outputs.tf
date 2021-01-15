output "app_security_group_id" {
  value       = module.app.security_group_id
  description = "ID of the security group for Frontend app instances."
}

output "alb_security_group_id" {
  value       = aws_security_group.public_alb.id
  description = "ID of the security group for the Frontend app's Internet-facing load balancer."
}

output "security_groups" {
  value       = module.app.security_groups
  description = "The security groups applied to the ECS Service."
}

output "task_definition_cli_input_json" {
  value       = module.task_definition_cli_input_json.cli_input_json
  description = <<DESCRIPTION
  Task definition JSON ready to be provided to
  
  ```
  aws ecs register-task-definition --cli-input-json ...
  ```

  The image in the first container definition is left blank, and should be
  overridden.
  DESCRIPTION
}