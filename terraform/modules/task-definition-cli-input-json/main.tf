variable "service_name" {
  type        = string
  description = "The name of the service, for example: content-store, draft-content-store, publisher-web or publisher-worker"
}
variable "mesh_name" {
  type = string
}
variable "port" {
  type    = string
  default = "80"
}
variable "environment_variables" {
  type    = map
  default = {}
}
variable "log_group" {
  type = string
}
variable "secrets_from_arns" {
  type    = map
  default = {}
}
variable "aws_region" {
  type = string
}
variable "depends_on_containers" {
  type        = map
  default     = {}
  description = "Other containers which this depends on (e.g. for envoy, set this to {envoy: \"START\"})"
}
variable "ports" {
  type    = list
  default = [80]
}
variable "cpu" {
  type = string
}
variable "memory" {
  type = string
}
variable "task_role_arn" {
  type = string
}
variable "execution_role_arn" {
  type = string
}

locals {
  # 1337 is an arbitrary choice copied from the examples in the envoy user guide.
  user_id = "1337"

  app_container_definition = {
    "name" : var.service_name,
    "essential" : true,
    "environment" : [for key, value in var.environment_variables : { name : key, value : tostring(value) }],
    "dependsOn" : [for key, value in var.depends_on_containers : { containerName : key, condition : value }],
    "logConfiguration" : {
      "logDriver" : "awslogs",
      "options" : {
        "awslogs-create-group" : "true", # TODO create the log group in terraform so we can configure the retention policy
        "awslogs-group" : var.log_group,
        "awslogs-region" : var.aws_region,
        "awslogs-stream-prefix" : var.service_name,
      }
    },
    "mountPoints" : [],
    "portMappings" : [
      for port in var.ports :
      { "ContainerPort" = "${port}",
        "hostPort"      = "${port}",
        "Protocol"      = "tcp",
      }
    ],
    "secrets" : [for key, value in var.secrets_from_arns : { name : key, valueFrom : value }]
  }

  # See the user guide at
  # https://docs.aws.amazon.com/app-mesh/latest/userguide/app-mesh-ug.pdf
  # for more details on configuring Envoy in AppMesh
  envoy_container_definition = {
    "name" : "envoy",
    # TODO: don't hardcode the version; track stable Envoy
    # TODO: control when Envoy updates happen (but still needs to be automatic)
    "image" : "840364872350.dkr.ecr.${var.aws_region}.amazonaws.com/aws-appmesh-envoy:v1.15.1.0-prod",
    "user" : local.user_id,
    "environment" : [
      { "name" : "APPMESH_RESOURCE_ARN", "value" : "mesh/${var.mesh_name}/virtualNode/${var.service_name}" },
    ],
    "essential" : true,
    "logConfiguration" : {
      "logDriver" : "awslogs",
      "options" : {
        "awslogs-create-group" : "true",
        "awslogs-group" : var.log_group,
        "awslogs-region" : var.aws_region,
        "awslogs-stream-prefix" : "awslogs-${var.service_name}-envoy"
      }
    }
  }

  envoy_proxy_properties = {
    AppPorts = var.port

    # From the user guide: "Envoy doesn't proxy traffic to these IP addresses.
    # Set this value to 169.254.170.2,169.254.169.254, which ignores the Amazon
    # EC2 metadata server and the Amazon ECS task metadata endpoint. The
    # metadata endpoint provides IAM roles for tasks credentials. You can add
    # additional addresses."
    EgressIgnoredIPs = "169.254.170.2,169.254.169.254"

    # From the user guide: The Envoy proxy doesn't route traffic from processes
    # that use this user ID. You can choose any userID that you want for this
    # property value, but this ID must be the same as the user ID for the
    # Envoy container in your task definition. This matching allows Envoy to
    # ignore its own traffic without usingthe proxy. Our examples use 1337 for
    # historical purposes.
    IgnoredUID = local.user_id

    # From the user guide: "This is the egress port for the Envoy proxy
    # container. Set this value to 15001."
    ProxyEgressPort = 15001

    # From the user guide: "This is the ingress port for the Envoy proxy
    # container. Set this value to 15000"
    ProxyIngressPort = 15000
  }
}

output "cli_input_json" {
  # Generated with: aws ecs register-task-definition --generate-cli-skeleton
  value = {
    family           = var.service_name,
    taskRoleArn      = "",
    executionRoleArn = "",
    networkMode      = "none",
    containerDefinitions = [
      local.app_container_definition,
      local.envoy_container_definition,
    ],
    requiresCompatibilities = ["FARGATE"],
    cpu                     = var.cpu,
    memory                  = var.memory,
    proxyConfiguration = {
      type          = "APPMESH",
      containerName = "envoy",
      properties    = [local.envoy_proxy_properties]
    }
  }
}
