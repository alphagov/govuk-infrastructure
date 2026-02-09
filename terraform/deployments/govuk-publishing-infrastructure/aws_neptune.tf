# cluster base defintion
resource "aws_neptune_cluster" "govuk_ai_accelerator_cluster" {
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
  publicly_accessible                 = false
  neptune_subnet_group_name           = "TBD"
}

# instances - 1 reader, 1 writer, inherit from cluster
resource "aws_neptune_cluster_instance" "govuk_ai_accelerator_instance" {
  count                               = 2
  cluster_identifier                  = aws_neptune_cluster.govuk_ai_accelerator_cluster.id
  engine                              = "neptune"
  instance_class                      = "db.r4.large"
  apply_immediately                   = true
}

# defined entry point to cluster
resource "aws_neptune_cluster_endpoint" "example" {
  cluster_identifier          = aws_neptune_cluster.test.cluster_identifier
  cluster_endpoint_identifier = "example"
  endpoint_type               = "READER"
}