locals {
  lambda_function_name = "${local.secret_name}_token_rotater"
  lambda_file_name     = "signon_bearer_token_rotater"
  permissions          = "signin"
}

resource "aws_lambda_function" "bearer_token" {
  filename      = "../../../lambdas/${local.lambda_file_name}.zip"
  function_name = local.lambda_function_name
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "${local.lambda_file_name}.handler"

  source_code_hash = filebase64sha256("../../../lambdas/${local.lambda_file_name}.zip")

  runtime = "ruby2.7"

  vpc_config {
    subnet_ids         = var.private_subnets
    security_group_ids = [var.signon_lambda_security_group_id]
  }

  environment {
    variables = {
      API_USER_EMAIL     = var.api_user_email
      APPLICATION_NAME   = var.app_name
      PERMISSIONS        = local.permissions
      ADMIN_PASSWORD_KEY = var.signon_admin_password_arn
      SIGNON_API_URL     = "http://${var.signon_host}/api/v1"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_iam_role_policy_attachment.vpc,
    aws_cloudwatch_log_group.bearer_token,
  ]

  tags = merge(
    var.additional_tags,
    {
      Name = "${local.lambda_function_name}-${var.environment}-${var.workspace}"
    },
  )

}

resource "aws_cloudwatch_log_group" "bearer_token" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = 90
}
