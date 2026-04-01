locals {
  secure_s3_bucket_search_relevancy_name = "govuk-${var.govuk_environment}-search-relevancy"
  secure_s3_bucket_search_relevancy_arn  = "arn:aws:s3:::${local.secure_s3_bucket_search_relevancy_name}"
}

module "secure_s3_bucket_search_relevancy" {
  source = "../../shared-modules/s3"

  govuk_environment = var.govuk_environment
  name              = local.secure_s3_bucket_search_relevancy_name

  lifecycle_rules = [
    {
      id         = "expire_training_data"
      status     = "Enabled"
      filter     = { prefix = "data/" }
      expiration = { days = 7 }
    },
    {
      id         = "expire_models"
      status     = "Enabled"
      filter     = { prefix = "model/" }
      expiration = { days = 7 }
    }
  ]
}

moved {
  from = aws_s3_bucket.search_relevancy_bucket
  to   = module.secure_s3_bucket_search_relevancy.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_logging.search_relevancy_bucket
  to   = module.secure_s3_bucket_search_relevancy.aws_s3_bucket_logging.this
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.search_relevancy_bucket
  to   = module.secure_s3_bucket_search_relevancy.aws_s3_bucket_lifecycle_configuration.this[0]
}

import {
  to = module.secure_s3_bucket_search_relevancy.aws_s3_bucket_versioning.this
  id = local.secure_s3_bucket_search_relevancy_name
}

import {
  to = module.secure_s3_bucket_search_relevancy.aws_s3_bucket_server_side_encryption_configuration.this
  id = local.secure_s3_bucket_search_relevancy_name
}
