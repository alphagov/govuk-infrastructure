module "state_file_bucket" {
  source = "../../shared-modules/s3"
  name   = "govuk-tools-state-files"

  govuk_environment = var.govuk_account

  extra_bucket_policies = [
    data.aws_iam_policy_document.s3_tools_state_file.json
  ]


  depends_on = [module.logging_bucket]
}

data "aws_iam_policy_document" "s3_tools_state_file" {
  statement {
    sid       = "AllowTFToGetState"
    actions   = ["s3:GetObject"]
    resources = ["${module.state_file_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/terraform-cloud"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}
