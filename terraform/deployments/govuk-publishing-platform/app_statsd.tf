module "statsd" {
  cluster_id                       = aws_ecs_cluster.cluster.id
  execution_role_arn               = aws_iam_role.execution.arn
  internal_domain_name             = var.internal_domain_name
  mesh_name                        = var.mesh_name
  private_subnets                  = local.private_subnets
  security_groups                  = [aws_security_group.mesh_ecs_service.id, local.govuk_management_access_sg_id]
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  source                           = "../../modules/statsd"
  task_role_arn                    = aws_iam_role.task.arn
  vpc_id                           = local.vpc_id
}

