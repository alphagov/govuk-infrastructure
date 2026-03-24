data "aws_iam_policy_document" "network_flow_agent_assume_role" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "network_flow_agent_role" {
  count = var.enable_container_network_observability == true ? 1 : 0

  name                  = "network-flow-agent-role"
  description           = "Network Flow Monitoring Agent IAM role"
  assume_role_policy    = data.aws_iam_policy_document.network_flow_agent_assume_role.json
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "network_flow_agent_role_policy" {
  count = var.enable_container_network_observability == true ? 1 : 0

  role       = aws_iam_role.network_flow_agent_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchNetworkFlowMonitorAgentPublishPolicy"
}

resource "aws_eks_pod_identity_association" "network_flow_agent" {
  count = var.enable_container_network_observability == true ? 1 : 0

  cluster_name    = var.cluster_name
  namespace       = "amazon-network-flow-monitoring"
  service_account = "network-flow-monitoring-agent"
  role_arn        = aws_iam_role.network_flow_agent_role[0].arn
}

resource "aws_networkflowmonitor_scope" "govuk" {
  count = var.enable_container_network_observability == true ? 1 : 0

  target {
    region = "eu-west-1"
    target_identifier {
      target_type = "ACCOUNT"
      target_id {
        account_id = data.aws_caller_identity.current.account_id
      }
    }
  }
}

resource "aws_networkflowmonitor_monitor" "govuk" {
  count = var.enable_container_network_observability == true ? 1 : 0

  monitor_name = "eks-govuk-monitor"
  scope_arn    = aws_networkflowmonitor_scope.govuk[0].scope_arn

  local_resource {
    type       = "AWS::EKS::Cluster"
    identifier = module.eks.cluster_arn
  }

  remote_resource {
    type       = "AWS::Region"
    identifier = "eu-west-1"
  }
}
