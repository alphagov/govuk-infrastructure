data "aws_iam_policy_document" "vpc_flow_logs_policy" {
  count = var.create_vpc_flow_logs ? 1 : 0

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "vpc_flow_logs_assume_policy" {
  count = var.create_vpc_flow_logs ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_cloudwatch_log_group" "log" {
  count = var.create_vpc_flow_logs ? 1 : 0

  name              = "govuk-vpc-flow-log"
  retention_in_days = var.cluster_log_retention_in_days
}

resource "aws_flow_log" "vpc_flow_log" {
  count = var.create_vpc_flow_logs ? 1 : 0

  log_destination = aws_cloudwatch_log_group.log[0].arn
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role[0].arn
  vpc_id          = data.tfe_outputs.vpc[0].nonsensitive_values.id
  traffic_type    = var.traffic_type
}

resource "aws_iam_role" "vpc_flow_logs_role" {
  count = var.create_vpc_flow_logs ? 1 : 0

  name               = "govuk-vpc-flow-logs"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_assume_policy[0].json
}

resource "aws_iam_policy" "vpc_flow_logs_policy" {
  count = var.create_vpc_flow_logs ? 1 : 0

  name   = "govuk-vpc-flow-logs-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.vpc_flow_logs_policy[0].json
}

resource "aws_iam_role_policy_attachment" "vpc_flow_logs_policy_attachment" {
  count = var.create_vpc_flow_logs ? 1 : 0

  role       = aws_iam_role.vpc_flow_logs_role[0].name
  policy_arn = aws_iam_policy.vpc_flow_logs_policy[0].arn
}
