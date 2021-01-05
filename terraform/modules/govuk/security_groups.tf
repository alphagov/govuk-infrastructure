# Security groups for the GOV.UK Publishing microservices are defined here.

resource "aws_security_group" "mesh_ecs_service" {
  name        = "mesh_ecs_service"
  vpc_id      = var.vpc_id
  description = "Associated with all ECS Services that are virtual services in the AppMesh mesh"
}
