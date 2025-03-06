locals {
  grafana_db_name         = "grafana-${module.eks.cluster_name}"
  grafana_service_account = "kube-prometheus-stack-grafana"
}

module "grafana_iam_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 5.0"
  create_role                   = true
  role_name                     = "${local.grafana_service_account}-${module.eks.cluster_name}"
  role_description              = "Role for Grafana to access AWS data sources. Corresponds to ${local.grafana_service_account} k8s ServiceAccount."
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [aws_iam_policy.grafana.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.monitoring_namespace}:${local.grafana_service_account}"]
}

data "aws_iam_policy_document" "grafana" {
  statement {
    sid    = "AllowReadingMetricsFromCloudWatch"
    effect = "Allow"
    actions = [
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetInsightRuleReport"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowReadingLogsFromCloudWatch"
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
      "logs:GetLogGroupFields",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:GetQueryResults",
      "logs:GetLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowReadingTagsInstancesRegionsFromEC2"
    effect = "Allow"
    actions = [
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowReadingResourcesForTags"
    effect = "Allow"
    actions = [
      "tag:GetResources"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "grafana" {
  name        = "grafana-${module.eks.cluster_name}"
  description = "Allows Grafana to access AWS data sources."

  # Values was obtained from
  # https://grafana.com/docs/grafana/latest/datasources/aws-cloudwatch/ (v8.4).
  policy = data.aws_iam_policy_document.grafana.json
}

data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "16"
  latest  = true
}

resource "random_password" "grafana_db" { length = 20 }

locals {
  rds_subnet_ids     = compact([for name, id in data.tfe_outputs.vpc.nonsensitive_values.private_subnet_ids : startswith(name, "rds_") ? id : ""])
  grafana_subnet_ids = startswith(var.govuk_environment, "eph-") ? [for sn in aws_subnet.eks_private : sn.id] : local.rds_subnet_ids
}

module "grafana_db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 9.0"

  name              = local.grafana_db_name
  database_name     = "grafana"
  engine            = "aurora-postgresql"
  engine_mode       = "provisioned"
  engine_version    = data.aws_rds_engine_version.postgresql.version
  storage_encrypted = true

  allow_major_version_upgrade = true

  vpc_id                 = data.tfe_outputs.vpc.nonsensitive_values.id
  subnets                = local.rds_subnet_ids
  create_db_subnet_group = true
  create_security_group  = true
  security_group_rules = {
    from_cluster = { source_security_group_id = module.eks.cluster_primary_security_group_id }
  }
  manage_master_user_password = false
  master_password             = random_password.grafana_db.result

  serverlessv2_scaling_configuration = {
    max_capacity             = 256
    min_capacity             = 0
    seconds_until_auto_pause = 300
  }

  apply_immediately            = var.rds_apply_immediately
  backup_retention_period      = var.rds_backup_retention_period
  skip_final_snapshot          = var.rds_skip_final_snapshot
  preferred_backup_window      = "02:00-03:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"
}

resource "aws_route53_record" "grafana_db" {
  zone_id = data.tfe_outputs.vpc.nonsensitive_values.internal_root_zone_id
  # TODO: consider removing EKS suffix once the old EC2 environments are gone.
  name    = "${local.grafana_db_name}-db.eks"
  type    = "CNAME"
  ttl     = 300
  records = [module.grafana_db.cluster_endpoint]
}

resource "aws_secretsmanager_secret" "grafana_db" {
  name                    = "${module.eks.cluster_name}/grafana/database"
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
}
