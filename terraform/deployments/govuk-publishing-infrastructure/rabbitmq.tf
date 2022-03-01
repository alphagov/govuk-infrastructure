locals {
  rabbitmq_name = "rabbitmq-${local.cluster_name}"
}

resource "aws_mq_broker" "rabbitmq_broker" {
  broker_name = local.rabbitmq_name

  engine_type                = "RabbitMQ"
  engine_version             = "3.8.27"
  storage_type               = "ebs"
  host_instance_type         = "mq.m5.large"
  security_groups            = [aws_security_group.rabbitmq.id]
  subnet_ids                 = [for sn in aws_subnet.rabbitmq : sn.id]
  authentication_strategy    = "simple"
  auto_minor_version_upgrade = true
  deployment_mode            = "CLUSTER_MULTI_AZ"

  logs {
    general = true
  }

  user {
    # NOTE: For engine_type of RabbitMQ, Amazon MQ does not return broker users
    # preventing this resource from making user updates and drift detection.
    # NOTE: AWS currently does not support updating RabbitMQ users.
    # Updates to users can only be in the RabbitMQ UI.
    username = "publishing_api"
    password = random_password.rabbitmq_password.result
  }

  tags = {
    Name = local.rabbitmq_name
  }
}

resource "aws_subnet" "rabbitmq" {
  for_each          = var.rabbitmq_subnets
  vpc_id            = data.terraform_remote_state.infra_vpc.outputs.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = "${local.rabbitmq_name}-${each.key}"
  }
}

resource "aws_security_group" "rabbitmq" {
  name        = local.rabbitmq_name
  vpc_id      = local.vpc_id
  description = "${local.rabbitmq_name} RabbitMQ broker"
  tags = {
    Name = local.rabbitmq_name
  }
}

resource "random_password" "rabbitmq_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "rabbitmq" {
  name = "govuk/common/${local.rabbitmq_name}"
}

resource "aws_secretsmanager_secret_version" "rabbitmq" {
  secret_id = aws_secretsmanager_secret.rabbitmq.id
  secret_string = jsonencode({
    password = random_password.rabbitmq_password.result
    hosts    = [for instance in aws_mq_broker.rabbitmq_broker.instances : instance.ip_address]
  })

  lifecycle {
    # NOTE: Ignored changes since password can be rotated in SecretsManager.
    ignore_changes = [secret_string]
  }
}
