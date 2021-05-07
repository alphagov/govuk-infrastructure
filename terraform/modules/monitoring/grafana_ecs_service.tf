resource "aws_ecs_service" "grafana" {
  name        = local.grafana_service_name
  cluster     = aws_ecs_cluster.cluster.id
  launch_type = "FARGATE"

  desired_count = var.grafana_desired_count

  health_check_grace_period_seconds = 60

  load_balancer {
    target_group_arn = module.grafana_public_alb.target_group_arn
    container_name   = local.grafana_container_name
    container_port   = var.grafana_port
  }

  network_configuration {
    security_groups = local.grafana_security_groups
    subnets         = var.private_subnets
  }

  task_definition = aws_ecs_task_definition.grafana.arn

  wait_for_steady_state = true
}


resource "aws_security_group" "grafana" {
  name        = "fargate_${local.grafana_service_name}-${var.workspace}"
  vpc_id      = var.vpc_id
  description = "${local.grafana_service_name} app ECS tasks"

  tags = merge(
    var.additional_tags,
    {
      Name = "${local.grafana_service_name}-${var.govuk_environment}-${var.workspace}"
    },
  )
}

resource "aws_security_group_rule" "grafana_to_any_any" {
  description       = "Grafana sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.grafana.id
}
