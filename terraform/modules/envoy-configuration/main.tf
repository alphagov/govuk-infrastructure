# See the user guide at
# https://docs.aws.amazon.com/app-mesh/latest/userguide/app-mesh-ug.pdf
# for more details on configuring Envoy in AppMesh

variable "mesh_name" {
  type = string
}

variable "service_name" {
  description = "Service name of the Fargate service, cluster, task etc."
  type        = string
}

variable "log_group" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "port" {
  type    = string
  default = "80"
}

locals {
  # 1337 is an arbitrary choice copied from the examples in the user guide.
  user_id = "1337"
}

output "container_definition" {
  value = {
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
}

output "proxy_properties" {
  value = {
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
