locals {
  chat_db_name = "chat-${module.eks.cluster_name}"
}

resource "random_password" "chat_db" { length = 20 }

module "chat_db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 9.0"

  name              = local.chat_db_name
  database_name     = "chat"
  engine            = "aurora-postgresql"
  engine_mode       = "serverless"
  engine_version    = "16"
  storage_encrypted = true

  allow_major_version_upgrade = true

  vpc_id                 = data.terraform_remote_state.infra_networking.outputs.vpc_id
  subnets                = data.terraform_remote_state.infra_networking.outputs.private_subnet_rds_ids
  create_db_subnet_group = true
  create_security_group  = true
  security_group_rules = {
    from_cluster = { source_security_group_id = local.node_security_group_id }
  }
  manage_master_user_password = false
  master_password             = random_password.chat_db.result

  scaling_configuration = {
    auto_pause               = var.chat_db_auto_pause
    min_capacity             = var.chat_db_min_capacity
    max_capacity             = var.chat_db_max_capacity
    seconds_until_auto_pause = var.chat_db_seconds_until_auto_pause
    timeout_action           = "ForceApplyCapacityChange"
  }

  apply_immediately            = var.rds_apply_immediately
  backup_retention_period      = var.rds_backup_retention_period
  skip_final_snapshot          = var.rds_skip_final_snapshot
  preferred_maintenance_window = "sun:02:00-sun:03:00"
}

resource "aws_route53_record" "chat_db" {
  zone_id = data.terraform_remote_state.infra_root_dns_zones.outputs.internal_root_zone_id
  # TODO: consider removing EKS suffix once the old EC2 environments are gone.
  name    = "${local.chat_db_name}-db.eks"
  type    = "CNAME"
  ttl     = 300
  records = [module.chat_db.cluster_endpoint]
}

resource "aws_secretsmanager_secret" "chat_db" {
  name                    = "${module.eks.cluster_name}/chat/database"
  recovery_window_in_days = var.secrets_recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "chat_db" {
  secret_id = aws_secretsmanager_secret.chat_db.id
  secret_string = jsonencode({
    "engine"   = "aurora"
    "host"     = aws_route53_record.chat_db.fqdn
    "username" = module.chat_db.cluster_master_username
    "password" = module.chat_db.cluster_master_password
    "dbname"   = local.chat_db_name
    "port"     = module.chat_db.cluster_port
  })
}
