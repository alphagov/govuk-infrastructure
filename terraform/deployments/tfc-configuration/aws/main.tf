data "tls_certificate" "tfc_certificate" {
  url = "https://${var.tfc_hostname}"
}

resource "aws_iam_openid_connect_provider" "tfc_provider" {
  url             = data.tls_certificate.tfc_certificate.url
  client_id_list  = ["aws.workload.identity"]
  thumbprint_list = [data.tls_certificate.tfc_certificate.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "tfc_role" {
  name = "terraform-cloud"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${aws_iam_openid_connect_provider.tfc_provider.arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${var.tfc_hostname}:aud" : "${one(aws_iam_openid_connect_provider.tfc_provider.client_id_list)}"
          },
          "StringLike" : {
            "${var.tfc_hostname}:sub" : "organization:${var.tfc_organization_name}:project:*:workspace:*:run_phase:*"
          }
        }
      }
    ]
  })

  managed_policy_arns = [aws_iam_policy.tfc_policy.arn]
}

resource "aws_iam_policy" "tfc_policy" {
  name        = "terraform-cloud-run"
  description = "Permissions to allow Terraform Cloud to plan and apply"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Resource" : "*",
        "Action" : [
          "acm:*",
          "apigateway:*",
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
          "iam:*",
          "kms:*",
          "lambda:*",
          "logs:*",
          "mq:*",
          "rds:*",
          "route53:*",
          "s3:*",
          "secretsmanager:*",
          "sns:*",
          "sqs:*",
          "wafv2:*"
        ]
      },
      {
        "Effect" : "Deny",
        "Resource" : "*",
        "Action" : [
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
          "iam:CreateServiceLinkedRole"
        ]
      }
    ]
  })
}

resource "tfe_variable_set" "variable_set" {
  name = "aws-credentials-${var.aws_environment}"
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
