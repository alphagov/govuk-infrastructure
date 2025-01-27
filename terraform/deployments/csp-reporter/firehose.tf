resource "aws_kinesis_firehose_delivery_stream" "delivery_stream" {
  name        = "govuk-${var.govuk_environment}-csp-reports-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.csp_reports.arn

    prefix              = "reports/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "errors/!{firehose:error-output-type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"

    buffering_size     = 64
    buffering_interval = 600

    data_format_conversion_configuration {
      input_format_configuration {
        deserializer {
          open_x_json_ser_de {}
        }
      }

      output_format_configuration {
        serializer {
          orc_ser_de {}
        }
      }

      schema_configuration {
        database_name = aws_glue_catalog_table.reports.database_name
        role_arn      = aws_iam_role.firehose_role.arn
        table_name    = aws_glue_catalog_table.reports.name
      }
    }
  }

  depends_on = [aws_iam_role_policy.firehose_glue_policy]
}

data "aws_iam_policy_document" "firehose_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "firehose_role" {
  name               = "govuk-${var.govuk_environment}-csp-reports-firehose-role"
  assume_role_policy = data.aws_iam_policy_document.firehose_role.json
}

# The firehose role policies are distinct so that we can apply this one
# before the kinesis delivery stream is set-up, as we need to use this access
# to create the delivery stream. The other ones aren't needed before the
# delivery stream's creation
data "aws_iam_policy_document" "firehose_glue_policy" {
  statement {
    effect = "Allow"
    actions = [
      "glue:GetTable",
      "glue:GetTableVersion",
      "glue:GetTableVersions"
    ]
    resources = [
      "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:catalog",
      aws_glue_catalog_database.csp_reports.arn,
      aws_glue_catalog_table.reports.arn
    ]
  }
}
resource "aws_iam_role_policy" "firehose_glue_policy" {
  name = "govuk-${var.govuk_environment}-csp-reports-firehose-glue-policy"
  role = aws_iam_role.firehose_role.id

  policy = data.aws_iam_policy_document.firehose_glue_policy.json
}

data "aws_iam_policy_document" "firehose_bucket_policy" {
  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.csp_reports.arn,
      "${aws_s3_bucket.csp_reports.arn}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards"
    ]
    resources = [aws_kinesis_firehose_delivery_stream.delivery_stream.arn]
  }
}

resource "aws_iam_role_policy" "firehose_bucket_policy" {
  name = "govuk-${var.govuk_environment}-csp-reports-firehose-bucket-policy"
  role = aws_iam_role.firehose_role.id

  policy = data.aws_iam_policy_document.firehose_bucket_policy.json
}

data "aws_iam_policy_document" "firehose_kinesis_policy" {
  statement {
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards"
    ]
    resources = [aws_kinesis_firehose_delivery_stream.delivery_stream.arn]
  }
}

resource "aws_iam_role_policy" "firehose_kinesis_policy" {
  name = "govuk-${var.govuk_environment}-csp-reports-firehose-kinesis-policy"
  role = aws_iam_role.firehose_role.id

  policy = data.aws_iam_policy_document.firehose_kinesis_policy.json
}
