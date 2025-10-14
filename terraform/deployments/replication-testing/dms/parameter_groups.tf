resource "aws_db_parameter_group" "content_data_api_source" {
  name   = "integration-jfharden-test-content-data-api-001-postgres-20251013162340024600000002"
  family = "postgres14"

  parameter {
    apply_method = "immediate"
    name         = "deadlock_timeout"
    value        = "2500"
  }
  parameter {
    apply_method = "immediate"
    name         = "log_lock_waits"
    value        = "1"
  }
  parameter {
    apply_method = "immediate"
    name         = "log_min_duration_statement"
    value        = "10000"
  }
  parameter {
    apply_method = "immediate"
    name         = "log_statement"
    value        = "all"
  }
  parameter {
    apply_method = "immediate"
    name         = "maintenance_work_mem"
    value        = "GREATEST({DBInstanceClassMemory/3072},65536)"
  }
  parameter {
    apply_method = "immediate"
    name         = "rds.force_autovacuum_logging_level"
    value        = "log"
  }
  parameter {
    apply_method = "immediate"
    name         = "work_mem"
    value        = "GREATEST({DBInstanceClassMemory/16384},65536)"
  }
  parameter {
    apply_method = "pending-reboot"
    name         = "autovacuum_max_workers"
    value        = "1"
  }
}

resource "aws_db_parameter_group" "content_data_api_target" {
  name   = "integration-jfharden-test-content-data-api-empty-001-postgres-20251014105356211500000002"
  family = "postgres14"

  parameter {
    apply_method = "immediate"
    name         = "deadlock_timeout"
    value        = "2500"
  }
  parameter {
    apply_method = "immediate"
    name         = "log_lock_waits"
    value        = "1"
  }
  parameter {
    apply_method = "immediate"
    name         = "log_min_duration_statement"
    value        = "10000"
  }
  parameter {
    apply_method = "immediate"
    name         = "log_statement"
    value        = "all"
  }
  parameter {
    apply_method = "immediate"
    name         = "maintenance_work_mem"
    value        = "GREATEST({DBInstanceClassMemory/3072},65536)"
  }
  parameter {
    apply_method = "immediate"
    name         = "rds.force_autovacuum_logging_level"
    value        = "log"
  }
  parameter {
    apply_method = "immediate"
    name         = "work_mem"
    value        = "GREATEST({DBInstanceClassMemory/16384},65536)"
  }
  parameter {
    apply_method = "pending-reboot"
    name         = "autovacuum_max_workers"
    value        = "1"
  }
}
