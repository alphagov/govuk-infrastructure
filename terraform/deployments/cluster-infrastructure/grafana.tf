locals {
  grafana_db_name         = "grafana-${module.eks.cluster_id}"
  grafana_service_account = "kube-prometheus-stack-grafana"
}

module "grafana_iam_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 4.0"
  create_role                   = true
  role_name                     = "${local.grafana_service_account}-${module.eks.cluster_id}"
  role_description              = "Role for Grafana to access AWS data sources. Corresponds to ${local.grafana_service_account} k8s ServiceAccount."
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [aws_iam_policy.grafana.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.monitoring_namespace}:${local.grafana_service_account}"]
}

resource "aws_iam_policy" "grafana" {
  name        = "grafana-${module.eks.cluster_id}"
  description = "Allows Grafana to access AWS data sources."

  # The argument to jsonencode() was obtained from
  # https://grafana.com/docs/grafana/latest/datasources/aws-cloudwatch/ (v8.4).
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowReadingMetricsFromCloudWatch",
        "Effect" : "Allow",
        "Action" : [
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetInsightRuleReport"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowReadingLogsFromCloudWatch",
        "Effect" : "Allow",
        "Action" : [
          "logs:DescribeLogGroups",
          "logs:GetLogGroupFields",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          "logs:GetLogEvents"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowReadingTagsInstancesRegionsFromEC2",
        "Effect" : "Allow",
        "Action" : ["ec2:DescribeTags", "ec2:DescribeInstances", "ec2:DescribeRegions"],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowReadingResourcesForTags",
        "Effect" : "Allow",
        "Action" : "tag:GetResources",
        "Resource" : "*"
      }
    ]
  })
}

module "grafana_db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 6.2.0"

  name              = local.grafana_db_name
  database_name     = "grafana"
  engine            = "aurora-postgresql"
  engine_mode       = "serverless"
  engine_version    = "10.14"
  storage_encrypted = true

  vpc_id                  = data.terraform_remote_state.infra_networking.outputs.vpc_id
  subnets                 = data.terraform_remote_state.infra_networking.outputs.private_subnet_rds_ids
  create_security_group   = true
  allowed_security_groups = [module.eks.node_security_group_id]

  db_parameter_group_name         = aws_db_parameter_group.grafana.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.grafana.id

  scaling_configuration = {
    auto_pause               = var.grafana_db_auto_pause
    min_capacity             = var.grafana_db_min_capacity
    max_capacity             = var.grafana_db_max_capacity
    seconds_until_auto_pause = var.grafana_db_seconds_until_auto_pause
    timeout_action           = "ForceApplyCapacityChange"
  }

  apply_immediately   = var.rds_apply_immediately
  skip_final_snapshot = var.rds_skip_final_snapshot
}

resource "aws_db_parameter_group" "grafana" {
  name   = "${local.grafana_db_name}-aurora-serverless-postgres10"
  family = "aurora-postgresql10"
}

resource "aws_rds_cluster_parameter_group" "grafana" {
  name   = "${local.grafana_db_name}-aurora-serverless-postgres10-cluster"
  family = "aurora-postgresql10"
}

resource "aws_route53_record" "grafana_db" {
  zone_id = data.terraform_remote_state.infra_root_dns_zones.outputs.internal_root_zone_id
  # TODO: consider removing EKS suffix once the old EC2 environments are gone.
  name    = "${local.grafana_db_name}-db.eks"
  type    = "CNAME"
  ttl     = 300
  records = [module.grafana_db.cluster_endpoint]
}

resource "aws_secretsmanager_secret" "grafana_db" {
  name                    = "${module.eks.cluster_id}/grafana/database"
  recovery_window_in_days = var.secrets_recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "grafana_db" {
  secret_id = aws_secretsmanager_secret.grafana_db.id
  secret_string = jsonencode({
    "engine"   = "aurora"
    "host"     = aws_route53_record.grafana_db.fqdn
    "username" = module.grafana_db.cluster_master_username
    "password" = module.grafana_db.cluster_master_password
    "dbname"   = local.grafana_db_name
    "port"     = module.grafana_db.cluster_port
  })

  lifecycle {
    ignore_changes = [secret_string] # So that password can be rotated in SecretsManager.
  }
}
