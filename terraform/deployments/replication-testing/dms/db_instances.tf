variable "encrypt_databases" {
  type        = bool
  description = "Whether to create encrypted snapshots and launch new instances from those snapshots"
  default     = true
}

resource "aws_db_instance" "content_data_api_source" {
  identifier            = "jfharden-test-content-data-api-001-postgres"
  engine                = "postgres"
  engine_version        = "14.18"
  instance_class        = "db.m6g.large"
  deletion_protection   = false
  apply_immediately     = true
  copy_tags_to_snapshot = true
  monitoring_interval   = 60
  monitoring_role_arn   = "arn:aws:iam::210287912431:role/rds-monitoring-role"
  skip_final_snapshot   = true
  multi_az              = true
  allocated_storage     = 1024
  parameter_group_name  = aws_db_parameter_group.content_data_api_source.name
  tags = {
    Name            = "jfharden-test-content-data-api-001-postgres"
    project         = "GOV.UK - Publishing"
    ReplicationType = "RecreateFromSnapshot"
  }
  password = random_password.content_data_api_source.result
}


resource "aws_db_instance" "content_data_api_source_encrypted" {
  count = var.encrypt_databases ? 1 : 0

  identifier            = "jfharden-test-content-data-api-001-postgres-encrypted"
  engine                = "postgres"
  engine_version        = "14.18"
  instance_class        = "db.m6g.large"
  deletion_protection   = false
  apply_immediately     = true
  copy_tags_to_snapshot = true
  monitoring_interval   = 60
  monitoring_role_arn   = "arn:aws:iam::210287912431:role/rds-monitoring-role"
  skip_final_snapshot   = true
  multi_az              = true
  allocated_storage     = 1024
  parameter_group_name  = aws_db_parameter_group.content_data_api_source.name
  tags = {
    Name            = "jfharden-test-content-data-api-001-postgres"
    project         = "GOV.UK - Publishing"
    ReplicationType = "DMS"
  }
  password            = random_password.content_data_api_source.result
  snapshot_identifier = aws_db_snapshot_copy.encrypted["jfharden-test-content-data-api-001-postgres"].target_db_snapshot_identifier
  storage_encrypted   = true
  kms_key_id          = aws_kms_key.rds.arn
}

resource "aws_db_instance" "whitehall" {
  identifier                   = "jfharden-test-whitehall-001-mysql"
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
  parameter_group_name         = aws_db_parameter_group.whitehall.name
  performance_insights_enabled = true
  tags = {
    Name            = "jfharden-test-whitehall-001-mysql"
    project         = "GOV.UK - Publishing"
    ReplicationType = "RecreateFromSnapshot"
  }
  password = random_password.whitehall.result
}

resource "aws_db_instance" "whitehall_encrypted" {
  count = var.encrypt_databases ? 1 : 0

  identifier                   = "jfharden-test-whitehall-001-mysql-encrypted"
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
  parameter_group_name         = aws_db_parameter_group.whitehall.name
  performance_insights_enabled = true
  tags = {
    Name            = "jfharden-test-whitehall-001-mysql"
    project         = "GOV.UK - Publishing"
    ReplicationType = "RecreateFromSnapshot"
  }
  password = random_password.whitehall.result

  snapshot_identifier = aws_db_snapshot_copy.encrypted["jfharden-test-whitehall-001-mysql"].target_db_snapshot_identifier
  storage_encrypted   = true
  kms_key_id          = aws_kms_key.rds.arn
}

resource "aws_db_instance" "publishing_api" {
  identifier            = "jfharden-test-publishing-api-postgres"
  engine                = "postgres"
  engine_version        = "13.20"
  instance_class        = "db.m6g.large"
  deletion_protection   = false
  apply_immediately     = true
  copy_tags_to_snapshot = true
  monitoring_interval   = 60
  monitoring_role_arn   = "arn:aws:iam::210287912431:role/rds-monitoring-role"
  skip_final_snapshot   = true
  multi_az              = true
  allocated_storage     = 1000
  parameter_group_name  = aws_db_parameter_group.publishing_api.name
  tags = {
    Name            = "jfharden-test-publishing-api-postgres"
    project         = "GOV.UK - Publishing"
    ReplicationType = "DMS"
  }
  password            = random_password.publishing_api.result
  snapshot_identifier = "rds:publishing-api-postgres-2025-10-17-01-12"
}

resource "aws_db_instance" "publishing_api_replica" {
  instance_class               = aws_db_instance.publishing_api.instance_class
  identifier                   = "${aws_db_instance.publishing_api.identifier}-replica"
  replicate_source_db          = aws_db_instance.publishing_api.identifier
  performance_insights_enabled = aws_db_instance.publishing_api.performance_insights_enabled

  performance_insights_retention_period = aws_db_instance.publishing_api.performance_insights_retention_period
  skip_final_snapshot                   = true

  tags = {
    Name            = "jfharden-test-publishing-api-postgres-replica"
    project         = "GOV.UK - Publishing"
    ReplicationType = "RecreateFromSnapshot"
  }
}

resource "aws_db_instance" "publishing_api_encrypted" {
  count = var.encrypt_databases ? 1 : 0

  identifier            = "jfharden-test-publishing-api-postgres-encrypted"
  engine                = "postgres"
  engine_version        = "13.20"
  instance_class        = "db.m6g.4xlarge"
  deletion_protection   = false
  apply_immediately     = true
  copy_tags_to_snapshot = true
  monitoring_interval   = 60
  monitoring_role_arn   = "arn:aws:iam::210287912431:role/rds-monitoring-role"
  skip_final_snapshot   = true
  multi_az              = true
  allocated_storage     = 1000
  parameter_group_name  = aws_db_parameter_group.publishing_api.name
  tags = {
    Name            = "jfharden-test-publishing-api-postgres-encrypted"
    project         = "GOV.UK - Publishing"
    ReplicationType = "DMS"
  }
  password            = random_password.publishing_api.result
  snapshot_identifier = aws_db_snapshot_copy.encrypted["jfharden-test-publishing-api-postgres"].target_db_snapshot_identifier
  storage_encrypted   = true
  kms_key_id          = aws_kms_key.rds.arn
}

resource "aws_db_instance" "publishing_api_replica_encrytped" {
  count = var.encrypt_databases ? 1 : 0

  instance_class               = aws_db_instance.publishing_api_encrypted[0].instance_class
  identifier                   = "${aws_db_instance.publishing_api_encrypted[0].identifier}-replica"
  replicate_source_db          = aws_db_instance.publishing_api_encrypted[0].identifier
  performance_insights_enabled = aws_db_instance.publishing_api_encrypted[0].performance_insights_enabled

  performance_insights_retention_period = 0
  skip_final_snapshot                   = true

  tags = {
    Name            = "jfharden-test-publishing-api-postgres-encrypted-replica"
    project         = "GOV.UK - Publishing"
    ReplicationType = "RecreateFromSnapshot"
  }
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn
}
