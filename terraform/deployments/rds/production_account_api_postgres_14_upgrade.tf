resource "aws_db_parameter_group" "service_manual_publisher_postgresql_14_green_params" {

  name_prefix = "${var.govuk_environment}-service-manual-publisher-postgres-"
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
