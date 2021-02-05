locals {
  definition = {
    containerDefinitions = [
      for definition in var.container_definitions : { for key, value in definition : key => value if value != null }
    ],
    cpu                     = var.cpu,
    executionRoleArn        = var.execution_role_arn,
    family                  = var.family,
    memory                  = var.memory,
    networkMode             = "awsvpc",
    proxyConfiguration      = var.proxy_configuration
    requiresCompatibilities = ["FARGATE"],
    taskRoleArn             = var.task_role_arn,
  }
}

output "cli_input_json" {
  value = { for key, value in local.definition : "${key}" => value if value != null }
}
