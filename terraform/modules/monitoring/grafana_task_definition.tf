locals {
  grafana_container_definition = {
    name        = local.grafana_container_name,
    essential   = true,
    environment = [for key, value in local.grafana_environment_variables : { name : key, value : tostring(value) }],
    healthCheck = {
      command     = ["/bin/bash", "-c", "wget -q -O - http://localhost:3000/api/health || exit 1"]
      startPeriod = 30
      retries     = 5
    }
    image = "${var.grafana_registry}/${var.grafana_image_name}:${var.grafana_image_tag}"
    # TODO: decide repository policy for non-govuk apps
    repositoryCredentials : {
      credentialsParameter : "arn:aws:secretsmanager:eu-west-1:430354129336:secret:dockerhub-govukci"
    }
    linuxParameters = {
      initProcessEnabled = true
    }
    logConfiguration = {
      logDriver = "splunk",
      options = {
        env               = "GOVUK_APP_NAME",
        tag               = "image_name={{.ImageName}} container_name={{.Name}} container_id={{.FullID}}",
        splunk-sourcetype = var.splunk_sourcetype,
        splunk-index      = var.splunk_index,
        splunk-format     = "raw"
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
    },
    mountPoints  = [],
    portMappings = [{ containerPort = var.grafana_port, hostPort = var.grafana_port, protocol = "tcp" }],
    secrets      = [for key, value in local.grafana_secrets_from_arns : { name = key, valueFrom = value }]
  }

  family = "${local.grafana_service_name}-${var.workspace}"
}

resource "aws_ecs_task_definition" "grafana" {
  family                   = local.family
  network_mode             = "awsvpc"
  cpu                      = var.grafana_cpu
  memory                   = var.grafana_memory
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.monitoring_execution.arn
  task_role_arn            = aws_iam_role.monitoring_task.arn
  container_definitions    = jsonencode([local.grafana_container_definition])

  tags = merge(
    var.additional_tags,
    {
      Name = "${local.family}-${var.govuk_environment}-${var.workspace}"
    },
  )
}
