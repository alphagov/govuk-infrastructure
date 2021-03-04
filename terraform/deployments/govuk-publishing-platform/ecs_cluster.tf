locals {
  mesh_name             = "${terraform.workspace == "default" ? var.mesh_name : "mesh-${terraform.workspace}"}"
}




# All services running on GOV.UK run in this single cluster.
resource "aws_ecs_cluster" "cluster" {
  name               = "govuk"
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = var.ecs_default_capacity_provider
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_appmesh_mesh" "govuk" {
  name = local.mesh_name

  spec {
    egress_filter {
      type = "ALLOW_ALL"
    }
  }
}

resource "aws_service_discovery_private_dns_namespace" "govuk_publishing_platform" {
  name = local.mesh_domain
  vpc  = local.vpc_id
}

resource "aws_iam_role" "execution" {
  name        = "fargate_execution_role"
  description = "Role for the ECS container agent and Docker daemon to manage the app container."

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

# TODO don't let tasks create their own log groups -
# create the log group in terraform
resource "aws_iam_policy" "create_log_group_policy" {
  name        = "create_log_group_policy"
  path        = "/createLogsGroupPolicy/"
  description = "Create Logs group"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "logs:CreateLogGroup",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Allow tasks to create log groups
resource "aws_iam_role_policy_attachment" "log_group_attachment_policy" {
  role       = aws_iam_role.execution.id
  policy_arn = aws_iam_policy.create_log_group_policy.arn
}

resource "aws_iam_role_policy_attachment" "task_exec_policy" {
  role       = aws_iam_role.execution.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Allow apps in ECS to access secrets.
#
# TODO: This allows *all* apps to access *any* secret. We should create a task execution
# role and policy for each app to permit apps to only access required secrets.
resource "aws_iam_policy" "access_secrets" {
  name        = "access_secrets"
  path        = "/accessSecretsPolicy/"
  description = "Allow apps in ECS to access secrets"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "arn:aws:secretsmanager:eu-west-1:430354129336:secret:*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "access_secrets_attachment_policy" {
  role       = aws_iam_role.execution.id
  policy_arn = aws_iam_policy.access_secrets.arn
}

# Proxy authorization for ECS tasks
# https://docs.aws.amazon.com/app-mesh/latest/userguide/proxy-authorization.html
resource "aws_iam_role" "task" {
  name        = "fargate_task_role"
  description = "Role for GOV.UK Publishing app containers (ECS tasks) to talk to other AWS services."

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "appmesh_envoy_access" {
  role       = aws_iam_role.task.id
  policy_arn = "arn:aws:iam::aws:policy/AWSAppMeshEnvoyAccess"
}
