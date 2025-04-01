data "aws_secretsmanager_secret" "slack_email" {
  count = startswith(var.govuk_environment, "eph-") ? 0 : 1
  name  = "govuk/slack/platform-support-email"
}

data "aws_secretsmanager_secret_version" "slack_email" {
  count     = startswith(var.govuk_environment, "eph-") ? 0 : 1
  secret_id = data.aws_secretsmanager_secret.slack_email[0].id
}

resource "aws_sns_topic" "slack_channel" {
  name         = "${var.cluster_name}-slack-alerts"
  display_name = "EKS CloudWatch alerts (${var.govuk_environment})"
}

resource "aws_sns_topic_subscription" "slack_channel" {
  count     = startswith(var.govuk_environment, "eph-") ? 0 : 1
  topic_arn = aws_sns_topic.slack_channel.arn
  protocol  = "email"
  endpoint  = data.aws_secretsmanager_secret_version.slack_email[0].secret_string
}

resource "aws_cloudwatch_metric_alarm" "node_group_limit" {
  for_each = local.eks_managed_node_groups

  alarm_name          = "${var.cluster_name}-${each.key}-node-group-limit"
  alarm_description   = "Cluster about to hit max node group size"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = each.value.max_size - 1
  evaluation_periods  = 2

  alarm_actions = [aws_sns_topic.slack_channel.arn]

  metric_query {
    id          = "count"
    return_data = true
    metric {
      metric_name = "GroupDesiredCapacity"
      namespace   = "AWS/AutoScaling"
      period      = 60
      stat        = "Maximum"

      dimensions = {
        AutoScalingGroupName = module.eks.eks_managed_node_groups[each.key].node_group_autoscaling_group_names[0]
      }
    }
  }
}
