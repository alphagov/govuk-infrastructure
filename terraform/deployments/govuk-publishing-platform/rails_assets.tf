locals {
  workspace_transformation = terraform.workspace == "default" ? "ecs" : terraform.workspace
}


resource "aws_s3_bucket" "rails_assets" {
  bucket = "govuk-${var.govuk_environment}-${local.workspace_transformation}-rails-assets"

  tags = {
    name            = "govuk-${var.govuk_environment}-${local.workspace_transformation}-rails-assets"
    aws_environment = var.govuk_environment
  }
}
