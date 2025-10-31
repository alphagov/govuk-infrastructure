resource "aws_db_instance" "content_data_api_target" {
  identifier             = "jfharden-test-content-data-api-empty-001"
  engine                 = "postgres"
  engine_version         = "14.18"
  instance_class         = "db.m6g.large"
  deletion_protection    = false
  apply_immediately      = true
  copy_tags_to_snapshot  = true
  monitoring_interval    = 60
  monitoring_role_arn    = "arn:aws:iam::210287912431:role/rds-monitoring-role"
  skip_final_snapshot    = true
  multi_az               = true
  allocated_storage      = 1024
  parameter_group_name   = aws_db_parameter_group.content_data_api_target.name
  vpc_security_group_ids = [data.aws_security_group.content_data_api_target.id]
  db_subnet_group_name   = "blue-govuk-rds-subnet"
  tags = {
    Name            = "jfharden-test-content-data-api-empty-001"
    project         = "GOV.UK - Publishing"
    ReplicationType = "DMS Homogenous Migration"
  }
  username          = "aws_db_admin"
  password          = random_password.content_data_api_target.result
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn
}

resource "aws_db_instance" "whitehall_target" {
  identifier                   = "jfharden-test-whitehall-empty-001"
  engine                       = "mysql"
  engine_version               = "8.0.42"
  instance_class               = "db.m7g.xlarge"
  deletion_protection          = false
  apply_immediately            = true
  copy_tags_to_snapshot        = true
  monitoring_interval          = 60
  monitoring_role_arn          = "arn:aws:iam::210287912431:role/rds-monitoring-role"
  skip_final_snapshot          = true
  multi_az                     = true
  allocated_storage            = 400
  parameter_group_name         = aws_db_parameter_group.whitehall_target.name
  performance_insights_enabled = true
  vpc_security_group_ids       = [data.aws_security_group.whitehall_target.id]
  db_subnet_group_name         = "blue-govuk-rds-subnet"
  tags = {
    Name            = "jfharden-test-whitehall-empty-001"
    project         = "GOV.UK - Publishing"
    ReplicationType = "DMS Homogenous Migration"
  }
  username          = "aws_db_admin"
  password          = random_password.whitehall_target.result
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn
}
