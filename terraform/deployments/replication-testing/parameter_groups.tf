resource "aws_db_parameter_group" "content_data_api_source" {
  name   = "integration-jfharden-test-content-data-api-001-postgres-20251013162340024600000002"
  family = "postgres14"

  parameter {
    apply_method = "pending-reboot"
    name         = "rds.logical_replication"
    value        = "1"
  }

  parameter {
    apply_method = "pending-reboot"
    name         = "max_worker_processes"
    value        = "15"
  }

  parameter {
    apply_method = "pending-reboot"
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements,pglogical"
  }

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
  name   = "jfharden-test-content-data-api-001-target"
  family = "postgres14"

  parameter {
    apply_method = "pending-reboot"
    name         = "rds.logical_replication"
    value        = "1"
  }

  parameter {
    apply_method = "immediate"
    name         = "session_replication_role"
    value        = "replica"
    # value = "origin"
  }

  parameter {
    apply_method = "pending-reboot"
    name         = "max_worker_processes"
    value        = "15"
  }

  parameter {
    apply_method = "pending-reboot"
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements,pglogical"
  }

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

resource "aws_db_parameter_group" "whitehall_source" {
  name   = "integration-jfharden-test-whitehall-001-mysql-20251013162340018300000001"
  family = "mysql8.0"

  parameter {
    apply_method = "immediate"
    name         = "max_allowed_packet"
    value        = "1073741824"
  }
}


resource "aws_db_parameter_group" "publishing_api" {
  name   = "integration-jfharden-test-publishing-api"
  family = "postgres13"

  parameter {
    apply_method = "pending-reboot"
    name         = "max_logical_replication_workers"
    value        = "20"
  }
  parameter {
    apply_method = "pending-reboot"
    name         = "rds.logical_replication"
    value        = "1"
  }
  parameter {
    apply_method = "immediate"
    name         = "checkpoint_timeout"
    value        = "3600"
  }
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
    name         = "max_wal_size"
    value        = "4096"
  }
  parameter {
    apply_method = "immediate"
    name         = "synchronous_commit"
    value        = "off"
  }
  parameter {
    apply_method = "pending-reboot"
    name         = "max_wal_senders"
    value        = "35"
  }
  parameter {
    apply_method = "pending-reboot"
    name         = "max_worker_processes"
    value        = "40"
  }
}
