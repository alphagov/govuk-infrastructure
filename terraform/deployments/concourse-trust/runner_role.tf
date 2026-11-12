locals {
  # The name of the Concourse deployment the runner role is for. Used in
  # resource names so that further Concourse deployments can be added later.
  concourse_name = "concourse"

  concourse_oidc_issuer_host = "concourse.tools.govuk.digital"
  concourse_oidc_audience    = "aws.oidc.${local.concourse_oidc_issuer_host}"
}

resource "aws_iam_openid_connect_provider" "concourse" {
  url            = "https://${local.concourse_oidc_issuer_host}"
  client_id_list = [local.concourse_oidc_audience]
}

module "terraform_runner_policy" {
  source = "../../shared-modules/terraform-runner-policy"
}

data "aws_iam_policy_document" "concourse_runner_assume_role" {
  statement {
    sid     = "AllowAssumeRoleFromConcourse"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.concourse.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.concourse_oidc_issuer_host}:aud"
      values   = [local.concourse_oidc_audience]
    }

    # TODO: This trusts every pipeline in the Concourse deployment. Restrict
    # it to specific "team/pipeline" subjects once those are known.
    condition {
      test     = "StringLike"
      variable = "${local.concourse_oidc_issuer_host}:sub"
      values   = ["*"]
    }
  }
}

resource "aws_iam_role" "concourse_runner" {
  name               = "concourse-runner-${local.concourse_name}"
  description        = "Assumed by the ${local.concourse_name} Concourse deployment to plan and apply Terraform"
  assume_role_policy = data.aws_iam_policy_document.concourse_runner_assume_role.json
}

resource "aws_iam_policy" "concourse_runner" {
  name        = "concourse-runner-${local.concourse_name}"
  description = "Permissions to allow the ${local.concourse_name} Concourse deployment to plan and apply Terraform"
  policy      = module.terraform_runner_policy.json
}

resource "aws_iam_role_policy_attachment" "concourse_runner" {
  role       = aws_iam_role.concourse_runner.name
  policy_arn = aws_iam_policy.concourse_runner.arn
}
