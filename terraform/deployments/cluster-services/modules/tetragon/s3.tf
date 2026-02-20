module "secure_s3_bucket" {
  source = "github.com/alphagov/govuk-infrastructure/terraform/shared-modules/s3?ref=3f260111d76ce69eeb1f6b9b8d3ea52e1bd467b4"

  name               = local.bucket_name
  versioning_enabled = true
  lifecycle_rules    = []
}
