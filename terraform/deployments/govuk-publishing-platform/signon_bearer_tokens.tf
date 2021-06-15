resource "aws_secretsmanager_secret" "signon_admin_password" {
  name                    = "signon_admin_password_${local.workspace}" # pragma: allowlist secret
  recovery_window_in_days = 0
}

# TODO: Replace the random_password approach with an autogenerate_secret module
# that runs a rotation lambda to createSecret.
resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.signon_admin_password.id
  secret_string = random_password.signon_admin_password.result
}

resource "random_password" "signon_admin_password" {
  length  = 64
  special = true
}

#
# SecretsManager Rotation Lambda
#

locals {
  bearer_token_lambda_name = "bearer_token_rotater-${local.workspace}"
}

data "archive_file" "bearer_token_rotater" {
  type        = "zip"
  source_file = "${path.module}/../../../lambdas/signon_bearer_token_rotater.rb"
  output_path = "${path.module}/../../../lambdas/signon_bearer_token_rotater.zip"
}

resource "aws_lambda_function" "bearer_token" {
  function_name = local.bearer_token_lambda_name
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "signon_bearer_token_rotater.handler"

  filename         = data.archive_file.bearer_token_rotater.output_path
  source_code_hash = data.archive_file.bearer_token_rotater.output_base64sha256

  runtime = "ruby2.7"

  vpc_config {
    subnet_ids         = local.private_subnets
    security_group_ids = [aws_security_group.signon_lambda.id]
  }

  environment {
    variables = {
      ADMIN_PASSWORD_KEY  = aws_secretsmanager_secret.signon_admin_password.arn
      DEPLOY_EVENT_BUCKET = aws_s3_bucket.deploy_event_bucket.id
      # TODO: Should be HTTPS
      SIGNON_API_URL = "http://${module.signon.virtual_service_name}/api/v1"
    }
  }

  # As recommended in Terraform docs
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_iam_role_policy_attachment.vpc,
    aws_cloudwatch_log_group.bearer_token,
  ]

  tags = merge(
    local.additional_tags,
    {
      Name = "${local.bearer_token_lambda_name}-${var.govuk_environment}-${local.workspace}"
    },
  )
}

resource "aws_cloudwatch_log_group" "bearer_token" {
  name              = "/aws/lambda/${local.bearer_token_lambda_name}"
  retention_in_days = 90
}

# Adds a trust policy to the lambda function.
resource "aws_lambda_permission" "allow_secretsmanager" {
  statement_id  = "AllowExecutionFromSecretsManager"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bearer_token.function_name
  principal     = "secretsmanager.amazonaws.com"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "${local.bearer_token_lambda_name}-execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "${local.bearer_token_lambda_name}-logging-policy"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secretsmanager_rotation" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.secretsmanager_rotation.arn
}

resource "aws_iam_policy" "secretsmanager_rotation" {
  name        = "${local.bearer_token_lambda_name}-rotation-policy"
  path        = "/"
  description = "Allow lambda to rotate a signon secret"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "secretsmanager:resource/AllowRotationLambdaArn" = aws_lambda_function.bearer_token.arn
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = aws_secretsmanager_secret.signon_admin_password.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vpc" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.vpc.arn
}

resource "aws_iam_policy" "vpc" {
  name        = "${local.bearer_token_lambda_name}_vpc_policy"
  path        = "/"
  description = "Allow lambda to interact with VPC"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces"
        ],
        Resource = "*",
        Effect   = "Allow"
      }
    ]
  })
}

#
# Signon bearer tokens
#

locals {
  # TODO Change this to local.public_domain once publishing.service domains
  # for backend apps are working.
  signon_api_url  = "https://signon.${local.workspace_external_domain}/api/v1"
  api_user_prefix = local.is_default_workspace ? null : local.workspace
  signon_api_user = {
    content_store = {
      app_name = "content-store"
      email    = join("-", compact([local.api_user_prefix, "content-store@${var.publishing_service_domain}"]))
    }
    draft_content_store = {
      app_name = "draft-content-store"
      email    = join("-", compact([local.api_user_prefix, "draft-content-store@${var.publishing_service_domain}"]))
    }
    frontend = {
      app_name = "frontend"
      email    = join("-", compact([local.api_user_prefix, "frontend@${var.publishing_service_domain}"]))
    }
    publisher = {
      app_name = "publisher"
      email    = join("-", compact([local.api_user_prefix, "publisher@${var.publishing_service_domain}"]))
    }
    publishing_api = {
      app_name = "publishing-api"
      email    = join("-", compact([local.api_user_prefix, "publishing-api@${var.publishing_service_domain}"]))
    }
  }

  signon_bearer_tokens = {
    cs_to_pub_api = {
      api_user   = local.signon_api_user.content_store.email
      app        = local.signon_app.publishing_api.name
      client_app = local.signon_api_user.content_store.app_name
    }

    cs_to_router_api = {
      api_user   = local.signon_api_user.content_store.email
      app        = local.signon_app.router_api.name
      client_app = local.signon_api_user.content_store.app_name
    }

    dcs_to_pub_api = {
      api_user   = local.signon_api_user.draft_content_store.email
      app        = local.signon_app.publishing_api.name
      client_app = local.signon_api_user.draft_content_store.app_name
    }

    dcs_to_draft_router_api = {
      api_user   = local.signon_api_user.draft_content_store.email
      app        = local.signon_app.draft_router_api.name
      client_app = local.signon_api_user.draft_content_store.app_name
    }

    pub_to_pub_api = {
      api_user   = local.signon_api_user.publisher.email
      app        = local.signon_app.publishing_api.name
      client_app = local.signon_api_user.publisher.app_name
    }

    pub_api_to_cs = {
      api_user   = local.signon_api_user.publishing_api.email
      app        = local.signon_app.content_store.name
      client_app = local.signon_api_user.publishing_api.app_name
    }

    pub_api_to_dcs = {
      api_user   = local.signon_api_user.publishing_api.email
      app        = local.signon_app.draft_content_store.name
      client_app = local.signon_api_user.publishing_api.app_name
    }

    pub_api_to_router_api = {
      api_user   = local.signon_api_user.publishing_api.email
      app        = local.signon_app.router_api.name
      client_app = local.signon_api_user.publishing_api.app_name
    }

    frontend_to_pub_api = {
      api_user   = local.signon_api_user.frontend.email
      app        = local.signon_app.publishing_api.name
      client_app = local.signon_api_user.frontend.app_name
    }
  }

  generated_bearer_tokens = {
    for user, user_data in local.signon_api_user :
    user => [
      for k, v in local.signon_bearer_tokens : module.signon_bearer_tokens[k].token_data
      if v.api_user == user_data.email
    ]
  }
}

module "signon_bearer_tokens" {
  for_each = local.signon_bearer_tokens
  source   = "../../modules/signon_bearer_token"

  additional_tags         = local.additional_tags
  app_name                = each.value.app
  aws_lambda_function_arn = aws_lambda_function.bearer_token.arn
  name                    = each.key
  environment             = var.govuk_environment
  workspace               = local.workspace
}
