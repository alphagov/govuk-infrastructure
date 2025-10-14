resource "aws_db_instance" "content_data_api_source" {
  identifier            = "jfharden-test-content-data-api-001-postgres"
  engine                = "postgres"
  engine_version        = "14.18"
  instance_class        = "db.m6g.large"
  deletion_protection   = true
  apply_immediately     = true
  copy_tags_to_snapshot = true
  monitoring_interval   = 60
  skip_final_snapshot   = true
  tags = {
    Name    = "govuk-rds-jfharden-test-content-data-api-001-postgres"
    project = "GOV.UK - Publishing"
  }
  password = random_password.content_data_api_source.result
}

resource "aws_db_instance" "content_data_api_target" {
  identifier            = "jfharden-test-content-data-api-empty-001-postgres"
  engine                = "postgres"
  engine_version        = "14.18"
  instance_class        = "db.m6g.large"
  deletion_protection   = true
  apply_immediately     = true
  copy_tags_to_snapshot = true
  monitoring_interval   = 60
  skip_final_snapshot   = true
  tags = {
    Name    = "govuk-rds-jfharden-test-content-data-api-empty-001-postgres"
    project = "GOV.UK - Publishing"
  }

  password = random_password.content_data_api_target.result
}
