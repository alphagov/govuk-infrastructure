locals {
  oidc_client_id = "aws.oidc.concourse.tools.govuk.digital"
}
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url = "https://concourse.tools.govuk.digital"
  client_id_list = [
    local.oidc_client_id
  ]
}

resource "aws_iam_role" "worker_role" {
  name = "concourse-worker-role"
  assume_role_policy = data.aws_iam_policy_document.worker_assume_role_policy.json
}

data "aws_iam_policy_document" "worker_assume_role_policy" {
  statement {
    sid     = "AllowAssumeRoleFromConcourse"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      identifiers = [
        aws_iam_openid_connect_provider.oidc_provider.arn
      ]
      type = "Federated"
    }

    condition {
      test     = "StringEquals"
      values   = [local.oidc_client_id]
      variable = "${local.oidc_client_id}:aud"
    }

    condition {
      test     = "StringEquals"
      values   = ["main/demo"]
      variable = "${local.oidc_client_id}:sub"
    }
  }
}
