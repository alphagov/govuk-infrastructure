resource "aws_security_group" "origin_alb" {
  name        = "fargate_${local.mode}_origin_${var.workspace_suffix}_alb"
  vpc_id      = var.vpc_id
  description = "${local.mode}-origin Internet-facing ALB in ${var.workspace_suffix} cluster"
}

resource "aws_security_group_rule" "service_from_origin_alb_http" {
  for_each                 = var.apps_security_config_list
  description              = "${each.key} receives requests from the ${local.mode}-origin ALB over HTTP"
  type                     = "ingress"
  from_port                = each.value.target_port
  to_port                  = each.value.target_port
  protocol                 = "tcp"
  security_group_id        = each.value.security_group_id
  source_security_group_id = aws_security_group.origin_alb.id
}

resource "aws_security_group_rule" "origin_alb_from_cidrs_https" {
  description       = "${local.mode}-origin ALB allows requests from CIDRs list over HTTPS"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.external_cidrs_list
  security_group_id = aws_security_group.origin_alb.id
}

resource "aws_security_group_rule" "origin_alb_to_any_any" {
  type      = "egress"
  protocol  = "-1"
  from_port = 0
  to_port   = 0

  security_group_id = aws_security_group.origin_alb.id
  cidr_blocks       = ["0.0.0.0/0"]
}

/// Cloudfront access to S3

resource "aws_iam_role" "cloudfront_security_groups_lambda_operator" {
  name               = "${var.workspace_suffix}_${local.mode}_cloudfront_security_groups_lambda"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
          ]
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}


resource "aws_iam_policy" "cloudfront_security_groups_lambda_policy" {
  name = "${var.workspace_suffix}_${local.mode}_cloudfront_security_groups_lambda_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "CloudWatchPermissions",
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*"
      },
      {
        "Sid" : "EC2Permissions",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeSecurityGroups",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:DescribeVpcs",
          "ec2:CreateTags",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:DescribeNetworkInterfaces",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:SetSecurityGroups"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudfront_security_groups_lambda_role_attachment" {
  role       = aws_iam_role.cloudfront_security_groups_lambda_operator.name
  policy_arn = aws_iam_policy.cloudfront_security_groups_lambda_policy.arn
}

data "archive_file" "cloudfront_security_groups_updater" {
  type        = "zip"
  output_path = "/tmp/cloudfront_security_groups_updater.zip"
  source_file = "${path.module}/cloudfront_security_groups_updater.py"
}

resource "aws_lambda_function" "cloudfront_security_groups_updater" {
  filename         = data.archive_file.cloudfront_security_groups_updater.output_path
  source_code_hash = data.archive_file.cloudfront_security_groups_updater.output_base64sha256
  function_name    = "${var.workspace_suffix}_${local.mode}_cloudfront_security_groups_updater"
  role             = aws_iam_role.cloudfront_security_groups_lambda_operator.arn
  timeout          = 300
  runtime          = "python3.8"
  handler          = "cloudfront_security_groups_updater.lambda_handler"

  environment {
    variables = {
      VPC_ID  = var.vpc_id
      PORTS   = "443"
      REGION  = var.aws_region
      ALB_ARN = aws_lb.origin.arn
      AD_SG   = aws_security_group.origin_alb.id
    }
  }
}
