locals {
  definition = {
    "command" : var.command,
    "essential" : true,
    "environment" : var.environment_variables,
    "dependsOn" : [{
      "containerName" : "envoy",
      "condition" : "START"
    }],
    "image" : "govuk/${var.service_name}:${var.image_tag}",
    "logConfiguration" : {
      "logDriver" : "awslogs",
      "options" : {
        "awslogs-create-group" : "true",
        "awslogs-group" : "awslogs-fargate",
        "awslogs-region" : "eu-west-1",
        "awslogs-stream-prefix" : "awslogs-${var.service_name}"
      }
    },
    "mountPoints" : [],
    "portMappings" : var.portMappings,
    "secrets" : var.secrets
  }
}
