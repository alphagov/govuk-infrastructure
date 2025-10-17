# module "dms_test_s3_bucket" {
#   source = "terraform-aws-modules/s3-bucket/aws"

#   bucket = "jfharden-dms-test"

#   control_object_ownership = true
#   object_ownership         = "BucketOwnerEnforced"

#   versioning = {
#     enabled = true
#   }

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }
