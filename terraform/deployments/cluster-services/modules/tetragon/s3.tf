module "secure_s3_bucket" {
  source = "../../../../shared-modules/s3/"

  name               = local.bucket_name
  versioning_enabled = true
  lifecycle_rules    = []
}
