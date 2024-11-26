resource "aws_ecr_registry_scanning_configuration" "ecr_scan" {
  scan_type = "ENHANCED"

  rule {
    scan_frequency = "SCAN_ON_PUSH"
    repository_filter {
      filter      = "*"
      filter_type = "WILDCARD"
    }
  }

  rule {
    scan_frequency = "CONTINUOUS_SCAN"
    repository_filter {
      filter      = "*"
      filter_type = "WILDCARD"
    }
  }
}

resource "aws_sns_topic" "ecr_scan_topic" {
  name = "ecr_scan_topic"
  tags = { Name = "ecr_scan_topic" }
}

resource "aws_sns_topic_policy" "ecr_scan_topic_policy" {
  arn    = aws_sns_topic.ecr_scan_topic.arn
  policy = data.aws_iam_policy_document.topic-policy-ecr-sns.json
}

resource "aws_sns_topic_subscription" "ecr_sns_subscription" {
  protocol  = "email"
  topic_arn = aws_sns_topic.ecr_scan_topic.arn
  for_each  = toset(var.emails)
  endpoint  = each.key
}

resource "aws_cloudwatch_event_rule" "event_rule" {
  name        = "vuln-findings"
  description = "A CloudWatch Event Rule that triggers when each ECR vulnerability image scan is completed. actions using AWS Lambda OR SNS."
  state       = "ENABLED"
  event_pattern = jsonencode({
    "source" : ["aws.ecr"],
    "detail-type" : ["ECR Image Scan"],
    "detail" : {
      "finding-severity-counts" : {
        "CRITICAL" : [{ "numeric" : [">", 0] }]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "event_rule_target" {
  rule = aws_cloudwatch_event_rule.event_rule.name
  arn  = aws_sns_topic.ecr_scan_topic.arn
}
