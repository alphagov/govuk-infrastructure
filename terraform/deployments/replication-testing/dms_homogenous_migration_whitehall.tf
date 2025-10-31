resource "awscc_dms_data_provider" "source_whitehall" {
  data_provider_name       = "whitehall-source"
  data_provider_identifier = "whitehall-source"
  engine                   = "mysql"
  description              = "Source mysql instance for whitehall"

  settings = {
    my_sql_settings = {
      port        = aws_db_instance.whitehall_source.port
      server_name = aws_db_instance.whitehall_source.address
      ssl_mode    = "require"
    }
  }

  tags = local.awscc_default_tags
}

resource "awscc_dms_data_provider" "target_whitehall" {
  data_provider_name       = "whitehall-target"
  data_provider_identifier = "whitehall-target"
  engine                   = "mysql"
  description              = "Target mysql instance for whitehall"

  settings = {
    my_sql_settings = {
      port        = aws_db_instance.whitehall_target.port
      server_name = aws_db_instance.whitehall_target.address
      ssl_mode    = "require"
    }
  }

  tags = local.awscc_default_tags
}

resource "awscc_dms_instance_profile" "dms_whitehall" {
  instance_profile_identifier = "jfharden-test-dms-homogenous-migration-whitehall"
  instance_profile_name       = "jfharden-test-dms-homogenous-migration-whitehall"
  description                 = "Profile created by JFHarden to test DMS migrations for Whitehall"
  network_type                = "IPV4"
  publicly_accessible         = false
  subnet_group_identifier     = aws_dms_replication_subnet_group.whitehall.id
  vpc_security_groups         = [aws_security_group.dms_whitehall.id]

  tags = local.awscc_default_tags

  depends_on = [
    aws_iam_role.dms-access-for-endpoint,
    aws_iam_role.dms-cloudwatch-logs-role,
    aws_iam_role.dms-vpc-role,
  ]
}

resource "awscc_dms_migration_project" "whitehall" {
  migration_project_name       = "jfharden-whitehall"
  migration_project_identifier = "jfharden-whitehall"
  instance_profile_arn         = awscc_dms_instance_profile.dms_whitehall.instance_profile_arn
  instance_profile_identifier  = awscc_dms_instance_profile.dms_whitehall.instance_profile_identifier
  instance_profile_name        = awscc_dms_instance_profile.dms_whitehall.instance_profile_name
  source_data_provider_descriptors = toset([{
    data_provider_arn               = awscc_dms_data_provider.source_whitehall.data_provider_arn
    data_provider_name              = awscc_dms_data_provider.source_whitehall.data_provider_name
    data_provider_identifier        = awscc_dms_data_provider.source_whitehall.data_provider_identifier
    secrets_manager_access_role_arn = aws_iam_role.dms-secret-access-role.arn
    secrets_manager_secret_id       = aws_secretsmanager_secret.whitehall_source_replication.id
  }])
  target_data_provider_descriptors = toset([{
    data_provider_arn               = awscc_dms_data_provider.target_whitehall.data_provider_arn
    data_provider_name              = awscc_dms_data_provider.target_whitehall.data_provider_name
    data_provider_identifier        = awscc_dms_data_provider.target_whitehall.data_provider_identifier
    secrets_manager_access_role_arn = aws_iam_role.dms-secret-access-role.arn
    secrets_manager_secret_id       = aws_secretsmanager_secret.whitehall_target_replication.id
  }])

  tags = local.awscc_default_tags

  lifecycle {
    ignore_changes = [
      source_data_provider_descriptors,
      target_data_provider_descriptors,
    ]
  }
}

resource "awscc_dms_data_migration" "whitehall" {
  data_migration_type          = "full-load"
  data_migration_identifier    = "jfharden-whitehall"
  data_migration_name          = "jfharden-whitehall"
  migration_project_identifier = awscc_dms_migration_project.whitehall.migration_project_arn
  service_access_role_arn      = aws_iam_role.dms-homogenous-migration.arn
  data_migration_settings = {
    cloudwatch_logs_enabled = true
  }

  tags = local.awscc_default_tags
}


resource "awscc_dms_data_migration" "whitehall_with_cdc" {
  data_migration_type          = "full-load-and-cdc"
  data_migration_identifier    = "jfharden-whitehall-with-cdc"
  data_migration_name          = "jfharden-whitehall-with-cdc"
  migration_project_identifier = awscc_dms_migration_project.whitehall.migration_project_arn
  service_access_role_arn      = aws_iam_role.dms-homogenous-migration.arn
  data_migration_settings = {
    cloudwatch_logs_enabled = true
  }

  tags = local.awscc_default_tags
}

# NOTE: The migration doesn't actually start, the above migration can be started with the command:
# aws dms start-data-migration --data-migration-identifier jfharden-whitehall --start-type start-replication
