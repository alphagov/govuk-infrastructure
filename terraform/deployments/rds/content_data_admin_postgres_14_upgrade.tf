resource "aws_db_parameter_group" "content_data_admin_postgresql_14_green_params" {

  name_prefix = "${var.govuk_environment}-content-data-admin-postgres-"
  family      = "postgres14"

  parameter {
    name         = "rds.logical_replication"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "max_logical_replication_workers"
    value        = "20"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "max_worker_processes"
    value        = "25"
    apply_method = "pending-reboot"
  }

  lifecycle { create_before_destroy = true }
}

import {
  to = aws_db_instance.instance["content_data_admin"]
  id = "content-data-admin-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["content_data_admin"]
  id = "integration-content-data-admin-postgres-20250814100650432600000001"
}
