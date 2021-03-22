locals {
  workspace_transformation = terraform.workspace == "default" ? "ecs" : terraform.workspace
}


resource "aws_s3_bucket" "rails_assets" {
  bucket = "govuk-${var.govuk_environment}-${local.workspace_transformation}-rails-assets"

  # Unless we're in staging or production, it's okay to delete this bucket
  # even if it still contains objects.
  #
  # In the lower environments, we want to be able to run `terraform destroy`
  # without having to manually delete all the assets from the bucket.
  force_destroy = contains(["staging", "production"], var.govuk_environment) ? false : true

  tags = {
    name            = "govuk-${var.govuk_environment}-${local.workspace_transformation}-rails-assets"
    aws_environment = var.govuk_environment
  }
}
