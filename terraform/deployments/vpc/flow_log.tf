data "aws_iam_policy_document" "vpc_flow_logs_policy" {
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
  name              = "govuk-vpc-flow-log"
  retention_in_days = var.cluster_log_retention_in_days
}

resource "aws_flow_log" "vpc_flow_log" {
  log_destination = aws_cloudwatch_log_group.log.arn
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
  vpc_id          = aws_vpc.vpc.id
  traffic_type    = var.traffic_type
}

resource "aws_iam_role" "vpc_flow_logs_role" {
  name               = "govuk-vpc-flow-logs"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_assume_policy.json
}

resource "aws_iam_policy" "vpc_flow_logs_policy" {
  name   = "govuk-vpc-flow-logs-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.vpc_flow_logs_policy.json
}

resource "aws_iam_role_policy_attachment" "vpc_flow_logs_policy_attachment" {
  role       = aws_iam_role.vpc_flow_logs_role.name
  policy_arn = aws_iam_policy.vpc_flow_logs_policy.arn
}
