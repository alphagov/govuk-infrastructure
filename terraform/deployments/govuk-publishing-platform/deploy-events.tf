resource "aws_s3_bucket" "deploy_event_bucket" {
  bucket = "deploy-event-${var.govuk_environment}-${terraform.workspace}"
  acl    = "private"

  tags = merge(
    local.additional_tags,
    {
      Name = "deploy-event-bucket-${var.govuk_environment}-${local.workspace}"
    },
  )

  # Deploy event objects are created out of Terraform.
  force_destroy = true
}
