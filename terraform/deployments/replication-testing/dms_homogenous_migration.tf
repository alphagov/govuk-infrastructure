resource "awscc_dms_data_provider" "source" {
  data_provider_name       = "content-data-api-source"
  data_provider_identifier = "content-data-api-source"
  engine                   = "postgres"
  description              = "Source postgres instance for content-data-api"

  settings = {
    postgre_sql_settings = {
      database_name = "content_performance_manager_production"
      port          = aws_db_instance.content_data_api_source.port
      server_name   = aws_db_instance.content_data_api_source.address
      ssl_mode      = "require"
    }
  }

  tags = local.awscc_default_tags
}

resource "awscc_dms_data_provider" "target" {
  data_provider_name       = "content-data-api-target"
  data_provider_identifier = "content-data-api-target"
  engine                   = "postgres"
  description              = "Target postgres instance for content-data-api"

  settings = {
    postgre_sql_settings = {
      database_name = "content_performance_manager_production"
      port          = aws_db_instance.content_data_api_target.port
      server_name   = aws_db_instance.content_data_api_target.address
      ssl_mode      = "require"
    }
  }

  tags = local.awscc_default_tags
}

resource "awscc_dms_instance_profile" "dms" {
  instance_profile_identifier = "jfharden-test-dms-homogenous-migration"
  instance_profile_name       = "jfharden-test-dms-homogenous-migration"
  description                 = "Profile created by JFHarden to test DMS migrations"
  network_type                = "IPV4"
  publicly_accessible         = false
  subnet_group_identifier     = aws_dms_replication_subnet_group.content_data_api.id
  vpc_security_groups         = [aws_security_group.dms.id]

  tags = local.awscc_default_tags

  depends_on = [
    aws_iam_role.dms-access-for-endpoint,
    aws_iam_role.dms-cloudwatch-logs-role,
    aws_iam_role.dms-vpc-role,
  ]
}

resource "awscc_dms_migration_project" "content_data_api" {
  migration_project_name       = "jfharden-content-data-api"
  migration_project_identifier = "jfharden-content-data-api"
  instance_profile_arn         = awscc_dms_instance_profile.dms.instance_profile_arn
  instance_profile_identifier  = awscc_dms_instance_profile.dms.instance_profile_identifier
  instance_profile_name        = awscc_dms_instance_profile.dms.instance_profile_name
  source_data_provider_descriptors = toset([{
    data_provider_arn               = awscc_dms_data_provider.source.data_provider_arn
    data_provider_name              = awscc_dms_data_provider.source.data_provider_name
    data_provider_identifier        = awscc_dms_data_provider.source.data_provider_identifier
    secrets_manager_access_role_arn = aws_iam_role.dms-secret-access-role.arn
    secrets_manager_secret_id       = aws_secretsmanager_secret.content_data_api_source_replication.id
  }])
  target_data_provider_descriptors = toset([{
    data_provider_arn               = awscc_dms_data_provider.target.data_provider_arn
    data_provider_name              = awscc_dms_data_provider.target.data_provider_name
    data_provider_identifier        = awscc_dms_data_provider.target.data_provider_identifier
    secrets_manager_access_role_arn = aws_iam_role.dms-secret-access-role.arn
    secrets_manager_secret_id       = aws_secretsmanager_secret.content_data_api_target_replication.id
  }])

  tags = local.awscc_default_tags

  lifecycle {
    ignore_changes = [
      source_data_provider_descriptors,
      target_data_provider_descriptors,
    ]
  }
}

resource "awscc_dms_data_migration" "content_data_api" {
  data_migration_type          = "full-load"
  data_migration_identifier    = "jfharden-content-data-api"
  data_migration_name          = "jfharden-content-data-api"
  migration_project_identifier = awscc_dms_migration_project.content_data_api.migration_project_arn
  service_access_role_arn      = aws_iam_role.dms-homogenous-migration.arn
  data_migration_settings = {
    cloudwatch_logs_enabled = true
  }

  tags = local.awscc_default_tags
}


resource "awscc_dms_data_migration" "content_data_api_with_cdc" {
  data_migration_type          = "full-load-and-cdc"
  data_migration_identifier    = "jfharden-content-data-api-with-cdc"
  data_migration_name          = "jfharden-content-data-api-with-cdc"
  migration_project_identifier = awscc_dms_migration_project.content_data_api.migration_project_arn
  service_access_role_arn      = aws_iam_role.dms-homogenous-migration.arn
  data_migration_settings = {
    cloudwatch_logs_enabled = true
  }

  tags = local.awscc_default_tags
}


# NOTE: The migration doesn't actually start, the above migration can be started with the command:
# aws dms start-data-migration --data-migration-identifier jfharden-content-data-api --start-type start-replication
