# Security groups for the GOV.UK Publishing microservices are defined here.

resource "aws_security_group" "mesh_ecs_service" {
  name        = "mesh_ecs_service-${terraform.workspace}"
  vpc_id      = local.vpc_id
  description = "Associated with all ECS Services that are virtual services in the AppMesh mesh"

  tags = merge(
    local.additional_tags,
    {
      Name = "mesh-ecs-service-${var.govuk_environment}-${local.workspace}"
    },
  )
}

resource "aws_security_group" "smokey" {
  name        = "ecs_fargate_smokey-${terraform.workspace}"
  vpc_id      = local.vpc_id
  description = "Smoke test runner"

  tags = merge(
    local.additional_tags,
    {
      Name = "ecs-fargate-smokey-${var.govuk_environment}-${local.workspace}"
    },
  )
}

resource "aws_security_group" "signon_lambda" {
  name        = "signon-lambda-${terraform.workspace}"
  vpc_id      = local.vpc_id
  description = "Signon Lambda"
}
