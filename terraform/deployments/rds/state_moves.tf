moved {
  from = aws_db_instance.normalised_instance
  to   = aws_db_instance.instance
}

moved {
  from = aws_cloudwatch_metric_alarm.normalised_rds_freestoragespace
  to   = aws_cloudwatch_metric_alarm.rds_freestoragespace
}

moved {
  from = aws_db_instance.normalised_replica
  to   = aws_db_instance.replica
}

moved {
  from = aws_security_group.normalised_rds
  to   = aws_security_group.rds
}

moved {
  from = aws_security_group_rule.normalised_rds_mysql
  to   = aws_security_group_rule.rds_mysql
}

moved {
  from = aws_security_group_rule.normalised_rds_postgres
  to   = aws_security_group_rule.rds_postgres
}
