locals {
  # 1337 is an arbitrary choice copied from the examples in the envoy user guide.
  user_id = "1337"

  family = "${var.service_name}-${terraform.workspace}"

  envoy_proxy_properties = {
    AppPorts = var.port

    # From the user guide: "Envoy doesn't proxy traffic to these IP addresses.
    # Set this value to 169.254.170.2,169.254.169.254, which ignores the Amazon
    # EC2 metadata server and the Amazon ECS task metadata endpoint. The
    # metadata endpoint provides IAM roles for tasks credentials. You can add
    # additional addresses."
    EgressIgnoredIPs = join(",", ["169.254.170.2", "169.254.169.254"])

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

module "app_container_definition" {
  source                = "../../modules/container-definition"
  image                 = "${var.registry}/${var.image_name}:${var.image_tag}"
  aws_region            = var.aws_region
  command               = var.command
  healthcheck_command   = var.container_healthcheck_command
  environment_variables = var.environment_variables
  dependsOn = concat(
    [{ containerName : "envoy", condition : "HEALTHY" }],
    var.container_dependencies
  )
  mount_points            = var.mount_points
  splunk_url_secret_arn   = var.splunk_url_secret_arn
  splunk_token_secret_arn = var.splunk_token_secret_arn
  splunk_sourcetype       = var.splunk_sourcetype
  splunk_index            = var.splunk_index
  name                    = "app"
  ports                   = [var.port]
  secrets_from_arns       = var.secrets_from_arns
}

# See the user guide at
# https://docs.aws.amazon.com/app-mesh/latest/userguide/app-mesh-ug.pdf
# for more details on configuring Envoy in AppMesh
module "envoy_container_definition" {
  source     = "../../modules/container-definition"
  aws_region = var.aws_region
  environment_variables = {
    APPMESH_RESOURCE_ARN = "mesh/${var.mesh_name}/virtualNode/${var.service_name}"
  }
  healthcheck_command = ["/bin/bash", "-c", "curl -f http://localhost:9901/ready || exit 1"]
  # TODO: don't hardcode the version; track stable Envoy
  # TODO: control when Envoy updates happen (but still needs to be automatic)
  image                   = "840364872350.dkr.ecr.${var.aws_region}.amazonaws.com/aws-appmesh-envoy:v1.16.1.0-prod"
  splunk_url_secret_arn   = var.splunk_url_secret_arn
  splunk_token_secret_arn = var.splunk_token_secret_arn
  splunk_sourcetype       = var.splunk_sourcetype
  splunk_index            = var.splunk_index
  name                    = "envoy"
  secrets_from_arns       = {}
  ports                   = []
  user                    = local.user_id
}

module "task_definition" {
  source = "../../modules/task-definition"
  container_definitions = concat([
    module.app_container_definition.json_format,
    module.envoy_container_definition.json_format,
  ], var.additional_containers)
  cpu                = var.cpu
  execution_role_arn = var.execution_role_arn
  family             = local.family
  memory             = var.memory
  proxy_configuration = {
    type          = "APPMESH",
    containerName = "envoy",
    properties    = [for key, value in local.envoy_proxy_properties : { name : key, value : tostring(value) }]
  }
  task_role_arn = var.task_role_arn
  volumes       = var.volumes
}

resource "aws_ecs_task_definition" "bootstrap" {
  family                   = local.family
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions = jsonencode(concat([
    module.app_container_definition.json_format,
    module.envoy_container_definition.json_format,
  ], var.additional_containers))

  proxy_configuration {
    type           = "APPMESH"
    container_name = "envoy"
    properties     = local.envoy_proxy_properties
  }

  dynamic "volume" {
    for_each = var.volumes
    content {
      name = volume.value["name"]
    }
  }

  tags = merge(
    var.additional_tags,
    {
      Name = "${local.family}-${var.environment}-${var.workspace}"
    },
  )

  lifecycle {
    # Makes tf plan/apply diffs less verbose.
    # This task definition is needed only for bootstrapping. We don't need
    # to update it, so we can ignore all changes.
    ignore_changes = all
  }
}

output "cli_input_json" {
  # Generated with: aws ecs register-task-definition --generate-cli-skeleton
  value = module.task_definition.cli_input_json
}
