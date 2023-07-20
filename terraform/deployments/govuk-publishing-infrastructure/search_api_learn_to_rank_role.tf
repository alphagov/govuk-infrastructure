locals {
  learn_to_rank_service_account_name = "search-api-learn-to-rank"
}

module "learn_to_rank_job_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name        = "${local.learn_to_rank_service_account_name}-${data.terraform_remote_state.cluster_infrastructure.outputs.cluster_id}"
  role_description = "Role for the Search API Learn to rank job. Corresponds to ${local.learn_to_rank_service_account_name} k8s ServiceAccount."

  oidc_providers = {
    main = {
      provider_arn               = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_oidc_provider_arn
      namespace_service_accounts = ["apps:${local.learn_to_rank_service_account_name}"]
    }
  }
}


data "aws_iam_policy_document" "learn_to_rank_job" {
  statement {
    actions = [
      "s3:Put*",
      "s3:List*",
      "s3:Get*",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::govuk-${var.govuk_environment}-search-relevancy/*",
      "arn:aws:s3:::govuk-${var.govuk_environment}-search-relevancy"
    ]
  }

  statement {
    actions = [
      "logs:GetLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "sagemaker:CreateTrainingJob",
      "sagemaker:DescribeTrainingJob",
      "sagemaker:CreateModel",
      "sagemaker:CreateEndpoint",
      "sagemaker:CreateEndpointConfig",
      "sagemaker:DeleteEndpoint",
      "sagemaker:DeleteEndpointConfig",
      "sagemaker:DeleteModel",
      "sagemaker:DescribeEndpoint",
      "sagemaker:DescribeEndpointConfig",
      "sagemaker:DescribeModel",
      "sagemaker:UpdateEndpoint",
      "sagemaker:UpdateEndpointWeightsAndCapacities"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "iam:PassRole"
    ]
    resources = ["arn:aws:iam::*:role/*"]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "learn_to_rank_job" {
  name        = "learn_to_rank_job"
  description = "Allow access to resources needed to train and deploy Sagemaker model"
  policy      = data.aws_iam_policy_document.learn_to_rank_job.json
}

resource "aws_iam_role_policy_attachment" "learn_to_rank_job" {
  role       = module.learn_to_rank_job_iam_role.iam_role_name
  policy_arn = aws_iam_policy.learn_to_rank_job.arn
}

data "aws_iam_policy_document" "learn_to_rank_sagemaker" {
  statement {
    actions = [
      "s3:Put*",
      "s3:List*",
      "s3:Get*",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::govuk-${var.govuk_environment}-search-relevancy/*",
      "arn:aws:s3:::govuk-${var.govuk_environment}-search-relevancy"
    ]
  }

  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:DescribeLogStreams",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "ecr:GetAuthorizationToken",
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/search"]
  }
}

data "aws_iam_policy_document" "learn_to_rank_sagemaker_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "learn_to_rank_sagemaker" {
  name               = "learn-to-rank-sagemaker"
  assume_role_policy = data.aws_iam_policy_document.learn_to_rank_sagemaker_assume_role_policy.json
}

resource "aws_iam_policy" "learn_to_rank_sagemaker" {
  name        = "learn_to_rank_sagemaker"
  description = "Permissions for sagemaker to train a model"
  policy      = data.aws_iam_policy_document.learn_to_rank_sagemaker.json
}

resource "aws_iam_role_policy_attachment" "learn_to_rank_sagemaker" {
  role       = aws_iam_role.learn_to_rank_sagemaker.name
  policy_arn = aws_iam_policy.learn_to_rank_sagemaker.arn
}
