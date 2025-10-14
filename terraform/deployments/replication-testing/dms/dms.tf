resource "aws_dms_replication_subnet_group" "content_data_api" {
  replication_subnet_group_description = "Subnet group for testing DMS replication"
  replication_subnet_group_id          = "jfharden-test-dms"

  subnet_ids = [
    aws_subnet.dms_a.id,
    aws_subnet.dms_b.id,
  ]

  tags = {
    Name = "jfharden-test-dms"
  }

  depends_on = [aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole]
}

# Create a new replication instance
resource "aws_dms_replication_instance" "content_data_api" {
  allocated_storage           = 200
  apply_immediately           = true
  multi_az                    = true
  engine_version              = "3.6.1"
  replication_instance_class  = "dms.r5.2xlarge"
  replication_instance_id     = "jfharden-content-data-api"
  replication_subnet_group_id = aws_dms_replication_subnet_group.content_data_api.id

  tags = {
    Name = "jfharden-content-data-api"
  }

  vpc_security_group_ids = [aws_security_group.dms.id]

  depends_on = [
    aws_iam_role_policy_attachment.dms-access-for-endpoint-AmazonDMSRedshiftS3Role,
    aws_iam_role_policy_attachment.dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole,
    aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole
  ]
}

resource "aws_dms_endpoint" "content_data_api_source" {
  endpoint_id   = "jfharden-test-content-data-api-001-postgres"
  endpoint_type = "source"
  engine_name   = "postgres"
  server_name   = "jfharden-test-content-data-api-001-postgres.ceu7s3y9xx35.eu-west-1.rds.amazonaws.com"
  port          = 5432
  database_name = "content_performance_manager_production"
  username      = "aws_db_admin"
  password      = random_password.content_data_api_source.result
  postgres_settings {
    authentication_method = "password"
    capture_ddls          = true
    plugin_name           = "pglogical"
  }
}

resource "aws_dms_endpoint" "content_data_api_target" {
  endpoint_id   = "jfharden-test-content-data-api-empty-001-postgres"
  endpoint_type = "target"
  engine_name   = "postgres"
  server_name   = "jfharden-test-content-data-api-empty-001-postgres.ceu7s3y9xx35.eu-west-1.rds.amazonaws.com"
  port          = 5432
  database_name = "content_performance_manager_production"
  username      = "aws_db_admin"
  password      = random_password.content_data_api_target.result
  postgres_settings {
    authentication_method = "password"
    capture_ddls          = true
    plugin_name           = "pglogical"
  }
}

/*

resource "aws_dms_replication_task" "content_data_api" {
  migration_type           = "full-load-and-cdc"
  replication_instance_arn = aws_dms_replication_instance.content_data_api.arn
  replication_task_id      = "jfharden-replicate-test-content-data-api"
  replication_task_settings = jsonencode({

  })
  resource_idntifier     = "jfharden-replicate-test-content-data-api"
  source_endpoint_arn    = aws_dms_endpoint.content_data_api_source.arn
  target_endpoint_arn    = aws_dms_endpoint.content_data_api_target.arn
  start_replication_task = false
}
*/
