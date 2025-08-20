locals {
  # only include cluster name if its an ephemeral cluster
  cloudwatch_query_suffix = var.cluster_name == "govuk" ? "" : " (${var.cluster_name})"
}

# CloudWatch Logs Insights query to find OOM-killed pods
resource "aws_cloudwatch_query_definition" "oom_killed_pods" {
  name = "Pods Killed (Out of Memory)${local.cloudwatch_query_suffix}"

  log_group_names = [module.eks.cloudwatch_log_group_name]

  query_string = file("cloudwatch_queries/oom_killed_pods.txt")
}
