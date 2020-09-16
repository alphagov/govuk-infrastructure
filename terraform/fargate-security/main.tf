#
# IAM role for Fargate tasks
#

terraform {
  backend "s3" {
    bucket  = "govuk-terraform-test"
    key     = "projects/fargate-iam.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  version = "~> 2.69"
  region  = "eu-west-1"
}

resource "aws_iam_role" "task_execution_role" {
  name = "fargate_task_execution_role"

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
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.create_log_group_policy.arn
}

# Attach managed AmazonECSTaskExecutionRolePolicy policy to task execution role
resource "aws_iam_role_policy_attachment" "task_exec_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


#
# Allow apps in ECS Fargate containers to access secrets
#
# This allows *all* apps to access *any* secret. We should create a task execution
# role and policy for each app to permit apps to only access required secrets.
#

resource "aws_iam_policy" "access_secrets" {
  name        = "access_secrets"
  path        = "/accessSecretsPolicy/"
  description = "Access AWS Secrets Manager secrets policy managed by Terraform"

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
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.access_secrets.arn
}

# Proxy authorization for ECS tasks
# https://docs.aws.amazon.com/app-mesh/latest/userguide/proxy-authorization.html

resource "aws_iam_role" "task_role" {
  name        = "fargate_task_role"
  description = "Allows ECS tasks to call ECS services (like AppMesh)."

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
  role       = aws_iam_role.task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSAppMeshEnvoyAccess"
}

resource "aws_iam_role_policy_attachment" "discover_instances" {
  role       = aws_iam_role.task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudMapDiscoverInstanceAccess"
}
