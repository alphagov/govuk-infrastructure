data "archive_file" "lambda_dist" {
  type        = "zip"
  source_file = "${path.module}/lambda-source/index.mjs"
  output_path = "${path.module}/lambda-source.zip"
}

resource "aws_lambda_function" "lambda" {
  filename         = data.archive_file.lambda_dist.output_path
  source_code_hash = data.archive_file.lambda_dist.output_base64sha256

  function_name = "CspReportsToFirehose"
  description   = "Handles Content Security Policy reports, passing valid ones to Kinesis Firehose"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"

  environment {
    variables = {
      FIREHOSE_DELIVERY_STREAM = aws_kinesis_firehose_delivery_stream.delivery_stream.name
    }
  }
}

data "aws_iam_policy_document" "lambda_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "govuk-${var.govuk_environment}-csp-reports-lambda-role"

  assume_role_policy = data.aws_iam_policy_document.lambda_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_service" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect    = "Allow"
    actions   = ["firehose:*"]
    resources = [aws_kinesis_firehose_delivery_stream.delivery_stream.arn]
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "govuk-${var.govuk_environment}-csp-reports-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = data.aws_iam_policy_document.lambda_policy.json
}

# AWS will automatically create a log group for the lambda at this location
# however that will have logs that are retained forever
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 30
}
