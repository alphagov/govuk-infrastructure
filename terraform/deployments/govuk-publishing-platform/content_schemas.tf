locals {
  content_schemas = {
    mount_point = {
      sourceVolume  = "content_schemas",
      containerPath = "/govuk-content-schemas",
      readOnly      = false
    }

    s3_bucket = "govuk-${var.govuk_environment}-${local.workspace}-content-schemas"
    volume    = { name = "content_schemas" }
  }
}

resource "aws_s3_bucket" "content_schemas" {
  bucket = local.content_schemas.s3_bucket

  # Unless we're in staging or production, it's okay to delete this bucket
  # even if it still contains objects.
  #
  # In the lower environments, we want to be able to run `terraform destroy`
  # without having to manually delete all the assets from the bucket.
  force_destroy = contains(["staging", "production"], var.govuk_environment) ? false : true

  tags = {
    name            = local.content_schemas.s3_bucket
    aws_environment = var.govuk_environment
  }
}

module "content_schemas_container_definition" {
  source              = "../../modules/container-definition"
  image               = "430354129336.dkr.ecr.eu-west-1.amazonaws.com/govuk/ecs-cli:latest"
  aws_region          = data.aws_region.current.name
  command             = ["/bin/sh", "-c", "aws s3 cp s3://${local.content_schemas.s3_bucket} $GOVUK_CONTENT_SCHEMAS_PATH --recursive"]
  essential           = false
  healthcheck_command = ["/bin/sh", "-c", "ls $GOVUK_CONTENT_SCHEMAS_PATH"]
  environment_variables = {
    GOVUK_CONTENT_SCHEMAS_PATH = local.content_schemas.mount_point.containerPath,
  }
  splunk_url_secret_arn   = local.defaults.splunk_url_secret_arn
  splunk_token_secret_arn = local.defaults.splunk_token_secret_arn
  splunk_index            = local.defaults.splunk_index
  splunk_sourcetype       = local.defaults.splunk_sourcetype
  name                    = "content_schemas_downloader"
  ports                   = []
  mount_points            = [local.content_schemas.mount_point]
}

resource "aws_iam_policy" "content_schemas_read_access_policy" {
  name        = "read_content_schemas-${terraform.workspace}"
  path        = "/readContentSchemas/"
  description = "Read Content Schemas S3 bucket"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : ["s3:ListBucket"],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${local.content_schemas.s3_bucket}"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : ["s3:GetObject"],
        "Resource" : [
          "arn:aws:s3:::${local.content_schemas.s3_bucket}/*"
        ]
      }
    ]
  })
}
