# IAM role for govuk-reports application with access to Cost Explorer, RDS, and tagging APIs

locals {
  govuk_reports_service_account_name = "govuk-reports"
}

# IAM policy document for govuk-reports permissions
data "aws_iam_policy_document" "govuk_reports_permissions" {
  # Cost Explorer permissions
  statement {
    sid = "CostExplorerAccess"
    actions = [
      "ce:GetCostAndUsage",
      "ce:GetDimensionValues",
      "ce:GetRightsizingRecommendation",
      "ce:ListCostCategoryDefinitions"
    ]
    resources = ["*"]
  }

  # RDS permissions
  statement {
    sid = "RDSAccess"
    actions = [
      "rds:DescribeDBInstances",
      "rds:DescribeDBEngineVersions",
      "rds:ListTagsForResource",
      "rds:DescribeDBSubnetGroups",
      "rds:DescribeDBParameterGroups"
    ]
    resources = ["*"]
  }

  # EC2 and tagging permissions
  statement {
    sid = "EC2AndTaggingAccess"
    actions = [
      "ec2:DescribeSecurityGroups",
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues"
    ]
    resources = ["*"]
  }
}

# IAM policy for govuk-reports
resource "aws_iam_policy" "govuk_reports" {
  name        = "govuk-${var.govuk_environment}-reports-policy"
  description = "Policy for govuk-reports application with access to Cost Explorer, RDS, and tagging APIs"
  policy      = data.aws_iam_policy_document.govuk_reports_permissions.json

  tags = {
    system      = "reports"
    environment = var.govuk_environment
    application = "govuk-reports"
  }
}

# IRSA role for govuk-reports service account
module "govuk_reports_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name            = "${local.govuk_reports_service_account_name}-${data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id}"
  role_description     = "Role for govuk-reports application. Corresponds to ${local.govuk_reports_service_account_name} k8s ServiceAccount."
  max_session_duration = 28800

  role_policy_arns = {
    govuk_reports_policy = aws_iam_policy.govuk_reports.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn
      namespace_service_accounts = ["apps:${local.govuk_reports_service_account_name}"]
    }
  }

  tags = {
    system      = "reports"
    environment = var.govuk_environment
    application = "govuk-reports"
  }
}

