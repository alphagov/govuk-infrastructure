moved {
  from = aws_db_instance.instance["chat"]
  to   = aws_db_instance.normalised_instance["chat"]
}

moved {
  from = aws_security_group.rds["chat"]
  to   = aws_security_group.normalised_rds["chat"]
}

moved {
  from = aws_security_group_rule.postgres["chat"]
  to   = aws_security_group_rule.normalised_rds_postgres["chat"]
}

moved {
  from = aws_cloudwatch_metric_alarm.rds_freestoragespace["chat"]
  to   = aws_cloudwatch_metric_alarm.normalised_rds_freestoragespace["chat"]
}
