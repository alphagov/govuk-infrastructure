resource "aws_neptune_cluster" "govuk_ai_accelerator" {
  cluster_identifier                  = "govuk-ai-accelerator-cluster"
  engine                              = "neptune"
  backup_retention_period             = 5
  preferred_backup_window             = "07:00-09:00"
  skip_final_snapshot                 = true
  iam_database_authentication_enabled = true
  apply_immediately                   = true
  iam_roles                           = data.aws_iam_roles.developer.arns
  storage_encrypted                   = true
  vpc_security_group_ids              = [aws_security_group.instance[each.key].id]
}
