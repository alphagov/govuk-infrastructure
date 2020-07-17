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
