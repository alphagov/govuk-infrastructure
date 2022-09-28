module "tag_ecr_images_iam_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 4.0"
  create_role                   = true
  role_name                     = "tag_ecr_images"
  role_description              = "IAM role for 'argo-workflow' service account to assume"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [aws_iam_policy.tag_ecr_images.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:apps:argo-workflow"]
}
data "aws_iam_policy_document" "tag_ecr_images" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:TagResource"
    ]
    resources = ["arn:aws:ecr:${data.aws_region.current.name}:172025368201:repository/*"]
  }
}
resource "aws_iam_policy" "tag_ecr_images" {
  name   = "tag_ecr_images"
  policy = data.aws_iam_policy_document.tag_ecr_images.json
}
