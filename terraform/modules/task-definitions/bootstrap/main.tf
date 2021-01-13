#--------------------------------------------------------------
# Bootstrapping image
#--------------------------------------------------------------

# TODO: Use a specially crafted bootstrap image here?
resource "aws_ecs_task_definition" "bootstrap" {
  family                   = var.service_name # must match the ECS Service LB name
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  container_definitions = jsonencode([
    {
      "name" : var.service_name,
      "image" : "840364872350.dkr.ecr.eu-west-1.amazonaws.com/aws-appmesh-envoy:v1.15.0.0-prod",
      "user" : "1337",
      "essential" : true,
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "awslogs-fargate",
          "awslogs-region" : "eu-west-1",
          "awslogs-stream-prefix" : "awslogs-bootstrap-envoy"
        }
      },
      "portMappings" : [
        for port in var.ports :
        { "ContainerPort" = "${port}",
          "hostPort"      = "${port}",
          "Protocol"      = "tcp",
        }
      ]
    }
  ])
}
