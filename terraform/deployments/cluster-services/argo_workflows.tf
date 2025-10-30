locals {
  tag_image_service_account_name = "add-tag-to-image-workflow"
}

module "tag_image_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 6.0"

  role_name        = "${local.tag_image_service_account_name}-${data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id}"
  role_description = "Role for the add-tag-to-image Argo Workflow. Corresponds to ${local.tag_image_service_account_name} k8s ServiceAccount."

  oidc_providers = {
    main = {
      provider_arn               = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn
      namespace_service_accounts = ["${var.apps_namespace}:${local.tag_image_service_account_name}"]
    }
  }
}

data "aws_iam_policy_document" "tag_image" {
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:PutImage",
    ]
    resources = ["arn:aws:ecr:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:repository/*"]
  }
}

resource "aws_iam_policy" "tag_image" {
  name        = "${local.tag_image_service_account_name}-${data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id}"
  description = "Allows Argo Workflows to tag images."
  policy      = data.aws_iam_policy_document.tag_image.json
}

resource "aws_iam_role_policy_attachment" "tag_image" {
  role       = module.tag_image_iam_role.iam_role_name
  policy_arn = aws_iam_policy.tag_image.arn
}
