data "aws_secretsmanager_secret" "smokey_auth_username" {
  name = "smokey_AUTH_USERNAME"
}

data "aws_secretsmanager_secret" "smokey_auth_password" {
  name = "smokey_AUTH_PASSWORD"
}

module "smokey_network_config" {
  source          = "../../modules/task-network-config"
  subnets         = local.private_subnets
  security_groups = [aws_security_group.smokey.id]
}

module "smokey_container_definition" {
  source     = "../../modules/container-definition"
  aws_region = data.aws_region.current.name
  environment_variables = {
    ENVIRONMENT = var.govuk_environment
  }
  log_group         = local.log_group
  log_stream_prefix = "smokey"
  secrets_from_arns = {
    AUTH_USERNAME = data.aws_secretsmanager_secret.smokey_auth_username.arn
    AUTH_PASSWORD = data.aws_secretsmanager_secret.smokey_auth_password.arn
  }
  ports = []
}

module "smokey_task_definition" {
  source                = "../../modules/task-definition-v2"
  container_definitions = [module.smokey_container_definition.json_format]
  cpu                   = 512
  execution_role_arn    = aws_iam_role.execution.arn
  family                = "smokey"
  memory                = 1024
  task_role_arn         = aws_iam_role.task.arn
}
