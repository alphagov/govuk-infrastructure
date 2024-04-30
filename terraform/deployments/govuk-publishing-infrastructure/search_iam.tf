# TODO: instead of granting access to nodes, use IRSA (IAM Roles for Service
# Accounts aka pod identity) to grant access specifically to Search.

data "aws_iam_policy_document" "search_relevancy_bucket_policy" {
  statement {
    sid       = "ReadListOfBuckets"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }

  statement {
    sid = "SearchRelevancyAccess"
    actions = [
      "s3:DeleteObject",
      "s3:Put*",
      "s3:Get*",
      "s3:List*",
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.search_relevancy_bucket.id}",
      "arn:aws:s3:::${aws_s3_bucket.search_relevancy_bucket.id}/*",
    ]
  }
}

resource "aws_iam_policy" "search_relevancy_bucket_access" {
  name        = "govuk-${var.govuk_environment}-search-relevancy-bucket-access-policy"
  policy      = data.aws_iam_policy_document.search_relevancy_bucket_policy.json
  description = "Allows reading and writing of the search relevancy bucket"
}

import {
  to = aws_iam_policy.search_relevancy_bucket_access
  id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/govuk-${var.govuk_environment}-search-relevancy-bucket-access-policy"
}

resource "aws_iam_role_policy_attachment" "search_relevancy_s3_eks_policy_attachment" {
  role       = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_name
  policy_arn = aws_iam_policy.search_relevancy_bucket_access.arn
}

data "aws_iam_policy_document" "sitemaps_bucket_policy" {
  statement {
    sid       = "ReadListOfBuckets"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
  statement {
    sid = "SitemapAccess"
    actions = [
      "s3:DeleteObject",
      "s3:Put*",
      "s3:Get*",
      "s3:List*",
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.search_sitemaps_bucket.id}",
      "arn:aws:s3:::${aws_s3_bucket.search_sitemaps_bucket.id}/*",
    ]
  }
}

resource "aws_iam_policy" "sitemaps_bucket_access" {
  name        = "govuk-${var.govuk_environment}-sitemaps-bucket-access-policy"
  policy      = data.aws_iam_policy_document.sitemaps_bucket_policy.json
  description = "Allows reading and writing of the sitemaps bucket"
}

import {
  to = aws_iam_policy.sitemaps_bucket_access
  id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/govuk-${var.govuk_environment}-sitemaps-bucket-access-policy"
}

resource "aws_iam_role_policy_attachment" "sitemaps_s3_eks_policy_attachment" {
  role       = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_name
  policy_arn = aws_iam_policy.sitemaps_bucket_access.arn
}

data "aws_iam_policy_document" "use_sagemaker" {
  statement {
    sid = "InvokeSagemaker"
    actions = [
      "sagemaker:DescribeEndpoint",
      "sagemaker:InvokeEndpoint",
    ]
    resources = ["arn:aws:sagemaker:*"]
  }
}

resource "aws_iam_policy" "use_sagemaker" {
  name        = "govuk-${var.govuk_environment}-search-use-sagemaker-policy"
  policy      = data.aws_iam_policy_document.use_sagemaker.json
  description = "Allows invoking and describing SageMaker endpoints"
}

import {
  to = aws_iam_policy.use_sagemaker
  id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/govuk-${var.govuk_environment}-search-use-sagemaker-policy"
}

resource "aws_iam_role_policy_attachment" "search_api_sagemaker_attachment" {
  role       = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_name
  policy_arn = aws_iam_policy.use_sagemaker.arn
}
