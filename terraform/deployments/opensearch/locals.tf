# Hard code local variable `snapshot_bucket_arns` with required bucket
# names per environment for IAM access in aws_iam_policy_document:
locals {
  snapshot_bucket_arns = <<EOF
  [
  %{if var.govuk_environment == "production"}
    "arn:aws:s3:::govuk-production-chat-opensearch-snapshots"
  %{endif}
  %{if var.govuk_environment == "staging"}
    "arn:aws:s3:::govuk-production-chat-opensearch-snapshots",
    "arn:aws:s3:::govuk-staging-chat-opensearch-snapshots"
  %{endif}
  %{if var.govuk_environment == "integration"}
    "arn:aws:s3:::govuk-staging-chat-opensearch-snapshots",
    "arn:aws:s3:::govuk-integration-chat-opensearch-snapshots"
  %{endif}
  ]
  EOF
}
