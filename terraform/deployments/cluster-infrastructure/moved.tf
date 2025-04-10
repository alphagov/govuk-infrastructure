moved {
  from = module.grafana_db.aws_db_subnet_group.this[0]
  to   = module.grafana_db[0].aws_db_subnet_group.this[0]
}

moved {
  from = module.grafana_db.aws_rds_cluster_instance.this["one"]
  to   = module.grafana_db[0].aws_rds_cluster_instance.this["one"]
}

moved {
  from = module.grafana_db.aws_rds_cluster.this[0]
  to   = module.grafana_db[0].aws_rds_cluster.this[0]
}

moved {
  from = module.grafana_db.aws_security_group_rule.this["from_cluster"]
  to   = module.grafana_db[0].aws_security_group_rule.this["from_cluster"]
}

moved {
  from = module.grafana_db.aws_security_group.this[0]
  to   = module.grafana_db[0].aws_security_group.this[0]
}
