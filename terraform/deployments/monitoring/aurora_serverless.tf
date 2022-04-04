locals {
  grafana_database_name = "grafana-${local.cluster_name}"
}


module "grafana_database" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "3.5.0"

  name              = local.grafana_database_name
  engine            = "aurora-mysql"
  engine_mode       = "serverless"
  engine_version    = "5.7.mysql_aurora.2.07.1"
  storage_encrypted = true
  database_name     = "grafana"

  vpc_id                = local.vpc_id
  subnets               = local.database_subnets
  create_security_group = true

  allowed_security_groups = [data.terraform_remote_state.cluster_infrastructure.outputs.cluster_security_group_id]

  db_parameter_group_name         = aws_db_parameter_group.grafana_database.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.grafana_database.id

  scaling_configuration = {
    auto_pause               = true
    min_capacity             = var.grafana_database_min_capacity
    max_capacity             = var.grafana_database_max_capacity
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }

  replica_count = 0

  apply_immediately = true
}

resource "aws_db_parameter_group" "grafana_database" {
  name        = "${local.grafana_database_name}-aurora-db-mysql-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${local.grafana_database_name}-aurora-db-mysql-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "grafana_database" {
  name        = "${local.grafana_database_name}-aurora-mysql-cluster-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${local.grafana_database_name}-aurora-mysql-cluster-parameter-group"
}

resource "aws_route53_record" "grafana_database" {
  zone_id = local.internal_dns_zone_id
  # TODO: consider removing EKS suffix once the old EC2 environments are gone.
  name    = "${local.grafana_database_name}-db.eks"
  type    = "CNAME"
  ttl     = 300
  records = [module.grafana_database.this_rds_cluster_endpoint]
}

resource "aws_secretsmanager_secret" "grafana_database" {
  name = "${local.cluster_name}/grafana/database"
}

resource "aws_secretsmanager_secret_version" "grafana_database" {
  secret_id = aws_secretsmanager_secret.grafana_database.id
  secret_string = jsonencode({
    "engine"   = "aurora"
    "host"     = aws_route53_record.grafana_database.fqdn
    "username" = module.grafana_database.this_rds_cluster_master_username
    "password" = module.grafana_database.this_rds_cluster_master_password
    "dbname"   = local.grafana_database_name
    "port"     = module.grafana_database.this_rds_cluster_port
  })

  lifecycle {
    # NOTE: Ignored changes since password can be rotated in SecretsManager.
    ignore_changes = [secret_string]
  }
}
