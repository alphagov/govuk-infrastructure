data "aws_iam_policy_document" "this" {
  statement {
    resources = ["*"]
    actions = [
      "access-analyzer:*",
      "acm:*",
      "apigateway:*",
      "athena:*",
      "autoscaling:*",
      "bedrock:DeleteModelInvocationLoggingConfiguration",
      "bedrock:GetModelInvocationLoggingConfiguration",
      "bedrock:PutModelInvocationLoggingConfiguration",
      "chatbot:*",
      "cloudfront:*",
      "cloudwatch:*",
      "codecommit:*",
      "ec2:*",
      "ecr:*",
      "eks:*",
      "elasticache:*",
      "elasticloadbalancing:*",
      "elasticfilesystem:*",
      "es:*",
      "events:*",
      "firehose:*",
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
      "networkflowmonitor:*",
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
    sid       = "AllowPassRoleToSelectAWSServices"
    actions   = ["iam:PassRole"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values = [
        "bedrock.amazonaws.com",
        "chatbot.amazonaws.com",
        "eks.amazonaws.com",
        "events.amazonaws.com",
        "firehose.amazonaws.com",
        "glue.amazonaws.com",
        "lambda.amazonaws.com",
        "monitoring.rds.amazonaws.com",
        "pods.eks.amazonaws.com",
        "rds.amazonaws.com",
        "s3.amazonaws.com",
      ]
    }
  }
  # separate iam:PassRole statement for roles that aren't
  # being passed to an AWS service
  statement {
    sid     = "AllowPassRoleOnSpecificRoles"
    actions = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::*:role/govuk-chat-bedrock-access-role",
    ]
  }
  statement {
    actions = ["iam:*Role"]
    resources = [
      "arn:aws:iam::*:role/AWSLambdaRole-transition-executor",
      "arn:aws:iam::*:role/basic_lambda_role"
    ]
  }
  statement {
    actions = ["iam:*User"]
    resources = [
      "arn:aws:iam::*:user/govuk-*-fastly-logs-writer",
      "arn:aws:iam::*:user/govuk-*-transition-downloader",
      "arn:aws:iam::*:user/govuk-*-fastly-logs-athena-monitoring"
    ]
  }
  statement {
    effect    = "Allow"
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["arn:aws:iam::*:role/aws-service-role/access-analyzer.amazonaws.com/AWSServiceRoleForAccessAnalyzer"]
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
    ]
  }
}
