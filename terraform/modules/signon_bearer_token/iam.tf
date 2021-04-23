# Adds a trust policy to the lambda function.
resource "aws_lambda_permission" "allow_secretsmanager" {
  statement_id  = "AllowExecutionFromSecretsManager"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bearer_token.function_name
  principal     = "secretsmanager.amazonaws.com"
  depends_on    = [aws_secretsmanager_secret.bearer_token]
}

resource "aws_iam_role" "lambda_execution_role" {
  name = local.secret_name

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
  name        = "${local.secret_name}_logging"
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
  name        = "${local.secret_name}_rotation_policy"
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
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = var.signon_admin_password_arn
      }
    ]
  })
}
