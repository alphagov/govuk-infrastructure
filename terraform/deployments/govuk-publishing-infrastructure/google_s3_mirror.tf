resource "aws_iam_role" "google-s3-mirror" {
  count = var.create_google_s3_mirror_role ? 1 : 0
  name  = "google-s3-mirror" # This is an historic role name and doesn't contain an environment name because it's in use elsewhere

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "accounts.google.com"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "accounts.google.com:sub" : "107768730699967087212"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "google-s3-mirror" {
  count       = var.create_google_s3_mirror_role ? 1 : 0
  name        = "google-s3-mirror"
  description = "Allows a Google Cloud Platform project to mirror S3 buckets."
  policy      = data.aws_iam_policy_document.google_s3_mirror[0].json
}

resource "aws_iam_role_policy_attachment" "google-s3-mirror-access" {
  count      = var.create_google_s3_mirror_role ? 1 : 0
  role       = aws_iam_role.google-s3-mirror[0].name
  policy_arn = aws_iam_policy.google-s3-mirror[0].arn
}

data "aws_iam_policy_document" "google_s3_mirror" {
  count = var.create_google_s3_mirror_role ? 1 : 0

  statement {
    sid = "GoogleReadBucket"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    # Need access to the top level of the tree.
    resources = [
      "arn:aws:s3:::govuk-${var.govuk_environment}-database-backups",
      "arn:aws:s3:::govuk-${var.govuk_environment}-database-backups/*",
    ]
  }
}

import {
  for_each = var.create_google_s3_mirror_role ? [1] : []

  to = aws_iam_role.google-s3-mirror[0]
  id = "google-s3-mirror"
}

import {
  for_each = var.create_google_s3_mirror_role ? [1] : []

  to = aws_iam_policy.google-s3-mirror[0]
  id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/google-s3-mirror"
}

import {
  for_each = var.create_google_s3_mirror_role ? [1] : []

  to = aws_iam_role_policy_attachment.google-s3-mirror-access[0]
  id = "google-s3-mirror/arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/google-s3-mirror"
}
