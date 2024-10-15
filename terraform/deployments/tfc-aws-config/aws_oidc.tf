data "tls_certificate" "tfc_certificate" {
  url = "https://${var.tfc_hostname}"
}

resource "aws_iam_openid_connect_provider" "tfc_provider" {
  url             = data.tls_certificate.tfc_certificate.url
  client_id_list  = ["aws.workload.identity"]
  thumbprint_list = [data.tls_certificate.tfc_certificate.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "tfc_role" {
  statement {
    principals {
      identifiers = [aws_iam_openid_connect_provider.tfc_provider.arn]
      type        = "Federated"
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${var.tfc_hostname}:aud"
      values   = [one(aws_iam_openid_connect_provider.tfc_provider.client_id_list)]
    }
    condition {
      test     = "StringLike"
      variable = "${var.tfc_hostname}:sub"
      values   = ["organization:${var.tfc_organization_name}:project:*:workspace:*:run_phase:*"]
    }
  }
}

resource "aws_iam_role" "tfc_role" {
  name                = "terraform-cloud"
  assume_role_policy  = data.aws_iam_policy_document.tfc_role.json
  managed_policy_arns = [aws_iam_policy.tfc_policy.arn]
}

data "aws_iam_policy_document" "tfc_policy" {
  statement {
    resources = ["*"]
    actions = [
      "acm:*",
      "apigateway:*",
      "athena:*",
      "autoscaling:*",
      "cloudfront:*",
      "cloudwatch:*",
      "ec2:*",
      "ecr:*",
      "eks:*",
      "elasticache:*",
      "elasticloadbalancing:*",
      "elasticfilesystem:*",
      "es:*",
      "events:*",
      "glue:*",
      "iam:*InstanceProfile*",
      "iam:*CloudFrontPublicKey*",
      "iam:*OpenIDConnectProvider*",
      "iam:*Policy",
      "iam:*Policies",
      "iam:*PolicyVersion*",
      "iam:*RolePolicies",
      "iam:*RoleTags",
      "iam:*Roles",
      "iam:*ServerCertificate*",
      "iam:*ServiceLinkedRole*",
      "iam:*SigningCertificate*",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateRole",
      "iam:SetDefaultPolicyVersion",
      "kms:*",
      "lambda:*",
      "logs:*",
      "mq:*",
      "pi:*", # Performance Insights
      "rds:*",
      "route53:*",
      "s3:*",
      "secretsmanager:*",
      "sns:*",
      "sqs:*",
      "wafv2:*"
    ]
  }
  statement {
    actions   = ["iam:PassRole"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values = [
        "eks.amazonaws.com",
        "s3.amazonaws.com",
      ]
    }
  }
  statement {
    actions = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::*:role/service-role/AWSGlueServiceRole*",
      "arn:aws:iam::*:role/AWSGlueServiceRole*",
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["glue.amazonaws.com"]
    }
  }
  statement {
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::*:role/rds-monitoring-role"]
  }
  statement {
    actions   = ["iam:*Role"]
    resources = ["arn:aws:iam::*:role/AWSLambdaRole-transition-executor"]
  }
  statement {
    actions   = ["iam:*User"]
    resources = ["arn:aws:iam::*:user/govuk-*-transition-downloader"]
  }
  statement {
    effect    = "Deny"
    resources = ["*"]
    actions = [
      "aws-marketplace:*",
      "aws-marketplace-management:*",
      "aws-portal:*",
      "budgets:*",
      "config:*",
      "directconnect:*",
      "ec2:*Purchase*",
      "ec2:*ReservedInstances*",
      "iam:*Login*",
      "iam:*Group*",
      "iam:*PermissionsBoundary*",
      "iam:*User*",
      "iam:CreateServiceLinkedRole",
    ]
  }
}

resource "aws_iam_policy" "tfc_policy" {
  name        = "terraform-cloud-run"
  description = "Permissions to allow Terraform Cloud to plan and apply"
  policy      = data.aws_iam_policy_document.tfc_policy.json
}

resource "tfe_variable_set" "variable_set" {
  name = "aws-credentials-${var.govuk_environment}"
}

resource "tfe_variable" "tfc_var_aws_provider_auth" {
  key             = "TFC_AWS_PROVIDER_AUTH"
  value           = "true"
  category        = "env"
  description     = "Configures Terraform Cloud to authenticate with AWS using dynamic credentials"
  variable_set_id = tfe_variable_set.variable_set.id
}

resource "tfe_variable" "tfc_var_aws_run_role_name" {
  key             = "TFC_AWS_RUN_ROLE_ARN"
  value           = aws_iam_role.tfc_role.arn
  category        = "env"
  description     = "The ARN of the role to assume in AWS"
  variable_set_id = tfe_variable_set.variable_set.id
}
