output "json_format" {
  value = {
    name        = var.name,
    command     = var.command,
    essential   = true,
    environment = [for key, value in var.environment_variables : { name : key, value : tostring(value) }],
    dependsOn   = var.dependsOn
    image       = var.image
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-create-group  = "true", # TODO create the log group in terraform so we can configure the retention policy
        awslogs-group         = var.log_group,
        awslogs-region        = var.aws_region,
        awslogs-stream-prefix = var.log_stream_prefix,
      }
    },
    mountPoints  = [],
    portMappings = [for port in var.ports : { containerPort = port, hostPort = port, protocol = "tcp" }],
    secrets      = [for key, value in var.secrets_from_arns : { name = key, valueFrom = value }]
    user         = var.user
  }
}
