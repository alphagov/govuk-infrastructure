locals {
  log_configuration_splunk = {
    logDriver = "splunk"
    options = {
      env               = "GOVUK_APP_NAME,GOVUK_ENVIRONMENT,GOVUK_WORKSPACE",
      tag               = "image_name={{.ImageName}} container_name={{.Name}} container_id={{.FullID}}",
      splunk-sourcetype = var.splunk_sourcetype,
      splunk-index      = var.splunk_index,
      splunk-format     = "json"
    }
    secretOptions = [
      {
        name      = "splunk-token",
        valueFrom = var.splunk_token_secret_arn
      },
      {
        name      = "splunk-url",
        valueFrom = var.splunk_url_secret_arn
      },
    ],
  }

  log_configuration_aws = {
    logDriver = "awslogs"
    options = {
      awslogs-create-group  = "true", # TODO create the log group in terraform so we can configure the retention policy
      awslogs-group         = var.log_group,
      awslogs-region        = var.aws_region,
      awslogs-stream-prefix = var.log_stream_prefix,
    },
    secretOptions = [],
  }
}

output "json_format" {
  value = {
    name        = var.name,
    command     = var.command,
    essential   = var.essential,
    environment = [for key, value in var.environment_variables : { name : key, value : tostring(value) }],
    dependsOn   = var.dependsOn
    healthCheck = {
      command     = var.healthcheck_command
      startPeriod = 30
      retries     = 5
    }
    image = var.image
    linuxParameters = {
      initProcessEnabled = true
    }
    logConfiguration = var.log_to_splunk ? local.log_configuration_splunk : local.log_configuration_aws
    mountPoints      = var.mount_points,
    portMappings     = [for port in var.ports : { containerPort = port, hostPort = port, protocol = "tcp" }],
    secrets          = [for key, value in var.secrets_from_arns : { name = key, valueFrom = value }]
    user             = var.user
  }
}

output "name" {
  value = var.name
}
