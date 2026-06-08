backup_retention_period       = 1
create_secure_db_dumps_bucket = true
skip_final_snapshot           = true
multi_az                      = false
maintenance_window            = "Sun:04:00-Sun:06:00"

databases = {
  account_api = {
    engine         = "postgres"
    engine_version = "14"
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
    }
    engine_params_family         = "postgres14"
    name                         = "account-api"
    allocated_storage            = 100
    instance_class               = "db.t4g.medium"
    performance_insights_enabled = true
    project                      = "GOV.UK - Web"
    snapshot_identifier          = "account-api-postgres-post-encryption"
    tags = {
      "used_by" = "account-api"
    }
  }

  authenticating_proxy = {
    engine         = "postgres"
    engine_version = "14"
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
      password_encryption        = { value = "md5" }
    }
    engine_params_family         = "postgres14"
    name                         = "authenticating-proxy"
    allocated_storage            = 100
    instance_class               = "db.t4g.micro"
    performance_insights_enabled = false
    project                      = "GOV.UK - Publishing"
    snapshot_identifier          = "authenticating-proxy-postgres-post-encryption"
    tags = {
      "used_by" = "authenticating-proxy"
    }
  }

  chat = {
    engine         = "postgres"
    engine_version = "16"
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
    }
    engine_params_family         = "postgres16"
    name                         = "chat"
    allocated_storage            = 100
    instance_class               = "db.t4g.small"
    performance_insights_enabled = false
    project                      = "GOV.UK - AI"
    snapshot_identifier          = "chat-postgres-post-encryption"
    tags = {
      "used_by" = "govuk-chat"
    }
  }

  ckan = {
    engine         = "postgres"
    engine_version = "14"
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
    }
    engine_params_family         = "postgres14"
    name                         = "ckan"
    allocated_storage            = 1000
    instance_class               = "db.m6g.large"
    performance_insights_enabled = true
    project                      = "GOV.UK - DGU"
    snapshot_identifier          = "ckan-postgres-post-encryption"
  }

  collections_publisher = {
    engine         = "mysql"
    engine_version = "8.0"
    engine_params = {
      max_allowed_packet = { value = 1073741824 }
    }
    engine_params_family         = "mysql8.0"
    name                         = "collections-publisher"
    allocated_storage            = 100
    instance_class               = "db.t4g.micro"
    performance_insights_enabled = false
    project                      = "GOV.UK - Publishing"
    snapshot_identifier          = "collections-publisher-mysql-post-encryption" #
    tags = {
      "used_by" = "collections-publisher"
    }
  }

  content_block_manager = {
    engine                      = "postgres"
    engine_version              = "17"
    allow_major_version_upgrade = true
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
    }
    engine_params_family         = "postgres17"
    name                         = "content-block-manager"
    allocated_storage            = 100
    instance_class               = "db.t4g.small"
    performance_insights_enabled = true
    project                      = "GOV.UK - Publishing"
    snapshot_identifier          = "content-block-manager-postgres-post-encryption"
    tags = {
      "used_by" = "content-block-manager"
    }
  }

  content_data_admin = {
    engine         = "postgres"
    engine_version = "14"
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
    }
    engine_params_family         = "postgres14"
    name                         = "content-data-admin"
    allocated_storage            = 100
    instance_class               = "db.t4g.micro"
    performance_insights_enabled = false
    project                      = "GOV.UK - Publishing"
    snapshot_identifier          = "content-data-admin-postgres-post-encryption"

    tags = {
      "used_by" = "content-data-admin"
    }
  }

  content_data_api = {
    engine         = "postgres"
    engine_version = "14"
    engine_params = {
      work_mem                             = { value = "GREATEST({DBInstanceClassMemory/${1024 * 16}},65536)" }
      autovacuum_max_workers               = { value = 1, apply_method = "pending-reboot" }
      maintenance_work_mem                 = { value = "GREATEST({DBInstanceClassMemory/${1024 * 3}},65536)" }
      "rds.force_autovacuum_logging_level" = { value = "log" }
      log_autovacuum_min_duration          = { value = 10000, apply_method = "pending-reboot" }
      log_min_duration_statement           = { value = "10000" }
      log_statement                        = { value = "all" }
      deadlock_timeout                     = { value = 2500 }
      log_lock_waits                       = { value = 1 }
    }
    engine_params_family         = "postgres14"
    name                         = "content-data-api"
    allocated_storage            = 1280
    instance_class               = "db.m6g.large"
    performance_insights_enabled = false
    project                      = "GOV.UK - Publishing"
    snapshot_identifier          = "blue-content-data-api-postgresql-primary-postgres-post-encryption"
    tags = {
      "used_by" = "content-data-api"
    }
  }

  content_store = {
    engine         = "postgres"
    engine_version = "14"
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
    }
    engine_params_family         = "postgres14"
    name                         = "content-store"
    allocated_storage            = 500
    instance_class               = "db.m6g.large"
    performance_insights_enabled = true
    project                      = "GOV.UK - Publishing"
    snapshot_identifier          = "content-store-postgres-post-encryption"
    tags = {
      "used_by" = "content-store"
    }
  }

  content_tagger = {
    engine         = "postgres"
    engine_version = "14"
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
    }
    engine_params_family         = "postgres14"
    name                         = "content-tagger"
    allocated_storage            = 100
    instance_class               = "db.t4g.small"
    performance_insights_enabled = false
    project                      = "GOV.UK - Publishing"
    snapshot_identifier          = "content-tagger-postgres-post-encryption"
    tags = {
      "used_by" = "content-tagger"
    }
  }

  draft_content_store = {
    engine         = "postgres"
    engine_version = "14"
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
    }
    engine_params_family         = "postgres14"
    name                         = "draft-content-store"
    allocated_storage            = 500
    instance_class               = "db.m6g.large"
    performance_insights_enabled = true
    project                      = "GOV.UK - Publishing"
    snapshot_identifier          = "draft-content-store-postgres-post-encryption"
    tags = {
      "used_by" = "content-store"
    }
  }

  email_alert_api = {
    engine         = "postgres"
    engine_version = "14"
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
    }
    engine_params_family         = "postgres14"
    name                         = "email-alert-api"
    allocated_storage            = 1000
    instance_class               = "db.m6g.large"
    performance_insights_enabled = true
    project                      = "GOV.UK - Web"
    snapshot_identifier          = "email-alert-api-postgres-post-encryption"

    tags = {
      "used_by" = "email-alert-api"
    }
  }

  fact_check_manager = {
    engine         = "postgres"
    engine_version = "17"
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
    }
    engine_params_family         = "postgres17"
    name                         = "fact-check-manager"
    allocated_storage            = 100
    instance_class               = "db.t4g.small"
    performance_insights_enabled = true
    project                      = "GOV.UK - Publishing"
    tags = {
      "used_by" = "fact-check-manager"
    }
  }

  govuk_ai_accelerator = {
    engine         = "postgres"
    engine_version = "17"
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
    }
    engine_params_family         = "postgres17"
    name                         = "govuk-ai-accelerator"
    allocated_storage            = 1000
    instance_class               = "db.m6g.large"
    performance_insights_enabled = true
    project                      = "GOV.UK - AI Accelerator"
    tags = {
      "used_by" = "govuk-ai-accelerator"
    }
  }

  link_checker_api = {
    engine         = "postgres"
    engine_version = "14"
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
    }
    engine_params_family         = "postgres14"
    name                         = "link-checker-api"
    allocated_storage            = 100
    instance_class               = "db.t4g.medium"
    performance_insights_enabled = false
    project                      = "GOV.UK - Publishing"
    maintenance_window           = "Mon:00:00-Mon:01:00"
    snapshot_identifier          = "link-checker-api-postgres-post-encryption"
    tags = {
      "used_by" = "link-checker-api"
    }
  }

  local_links_manager = {
    engine         = "postgres"
    engine_version = "14"
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
    }
    engine_params_family         = "postgres14"
    name                         = "local-links-manager"
    allocated_storage            = 100
    instance_class               = "db.t4g.small"
    performance_insights_enabled = false
    project                      = "GOV.UK - Web"
    snapshot_identifier          = "local-links-manager-postgres-post-encryption"
    tags = {
      "used_by" = "local-links-manager"
    }
  }

  locations_api = {
    engine         = "postgres"
    engine_version = "14"
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
    }
    engine_params_family         = "postgres14"
    name                         = "locations-api"
    allocated_storage            = 1000
    instance_class               = "db.m6g.large"
    performance_insights_enabled = true
    project                      = "GOV.UK - Web"
    snapshot_identifier          = "locations-api-postgres-post-encryption"
    tags = {
      "used_by" = "locations-api"
    }
  }

  places_manager = {
    engine         = "postgres"
    engine_version = "14"
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
      password_encryption        = { value = "md5" }
    }
    engine_params_family         = "postgres14"
    name                         = "places-manager"
    allocated_storage            = 100
    instance_class               = "db.t4g.medium"
    performance_insights_enabled = false
    project                      = "GOV.UK - Web"
    snapshot_identifier          = "imminence-postgres-post-encryption"
    tags = {
      "used_by" = "places-manager"
    }
  }

  publisher = {
    engine                      = "postgres"
    engine_version              = "17"
    allow_major_version_upgrade = true
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
    }
    engine_params_family         = "postgres17"
    name                         = "publisher"
    allocated_storage            = 100
    instance_class               = "db.t4g.small"
    performance_insights_enabled = true
    project                      = "GOV.UK - Publishing"
    snapshot_identifier          = "publisher-postgres-post-encryption"
    tags = {
      "used_by" = "publisher"
    }
  }

  publishing_api = {
    engine                 = "postgres"
    engine_version         = "17"
    replica_engine_version = "17"
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
      checkpoint_timeout         = { value = 3600 }
      max_wal_size               = { value = 4096 }
      synchronous_commit         = { value = "off" }
    }
    engine_params_family         = "postgres17"
    name                         = "publishing-api"
    allocated_storage            = 1000
    iops                         = 24000
    storage_throughput           = 1000
    instance_class               = "db.m6g.large"
    performance_insights_enabled = true
    project                      = "GOV.UK - Publishing"
    has_read_replica             = true
    tags = {
      "used_by" = "publishing-api"
    }
  }

  release = {
    engine         = "mysql"
    engine_version = "8.4"
    engine_params = {
      max_allowed_packet = { value = 1073741824 }
    }
    engine_params_family         = "mysql8.4"
    name                         = "release"
    allocated_storage            = 100
    instance_class               = "db.t4g.micro"
    performance_insights_enabled = false
    project                      = "GOV.UK - Infrastructure"
    snapshot_identifier          = "release-mysql-post-encryption"
    tags = {
      "used_by" = "release"
    }
  }

  search_admin = {
    engine         = "mysql"
    engine_version = "8.0"
    engine_params = {
      max_allowed_packet = { value = 1073741824 }
    }
    engine_params_family         = "mysql8.0"
    name                         = "search-admin"
    allocated_storage            = 100
    instance_class               = "db.t4g.micro"
    performance_insights_enabled = false
    project                      = "GOV.UK - Search"
    snapshot_identifier          = "search-admin-mysql-post-encryption"
    tags = {
      "used_by" = "search-admin"
    }
  }

  service_manual_publisher = {
    engine         = "postgres"
    engine_version = "14"
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
    }
    engine_params_family         = "postgres14"
    name                         = "service-manual-publisher"
    allocated_storage            = 100
    instance_class               = "db.t4g.small"
    performance_insights_enabled = false
    project                      = "GOV.UK - Publishing"
    snapshot_identifier          = "service-manual-publisher-postgres-post-encryption"
    tags = {
      "used_by" = "service-manual-publisher"
    }
  }

  signon = {
    engine         = "mysql"
    engine_version = "8.0"
    engine_params = {
      max_allowed_packet = { value = 1073741824 }
    }
    engine_params_family         = "mysql8.0"
    name                         = "signon"
    allocated_storage            = 100
    instance_class               = "db.t4g.medium"
    performance_insights_enabled = true
    project                      = "GOV.UK - Publishing"
    snapshot_identifier          = "signon-mysql-post-encryption"
    tags = {
      "used_by" = "signon"
    }
  }

  support_api = {
    engine         = "postgres"
    engine_version = "14"
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
    }
    engine_params_family         = "postgres14"
    name                         = "support-api"
    allocated_storage            = 200
    instance_class               = "db.t4g.medium"
    performance_insights_enabled = true
    project                      = "GOV.UK - Publishing"
    snapshot_identifier          = "support-api-postgres-post-encryption"
    tags = {
      "used_by" = "support-api"
    }
  }

  transition = {
    engine         = "postgres"
    engine_version = "14"
    engine_params = {
      log_min_duration_statement = { value = 10000 }
      log_statement              = { value = "all" }
      deadlock_timeout           = { value = 2500 }
      log_lock_waits             = { value = 1 }
    }
    engine_params_family         = "postgres14"
    name                         = "transition"
    allocated_storage            = 120
    instance_class               = "db.m6g.large"
    performance_insights_enabled = true
    project                      = "GOV.UK - Publishing"
    snapshot_identifier          = "transition-postgres-post-encryption"
    tags = {
      "used_by" = "transition"
    }
  }

  whitehall = {
    engine         = "mysql"
    engine_version = "8.0"
    engine_params = {
      max_allowed_packet = { value = 1073741824 }
    }
    engine_params_family         = "mysql8.0"
    name                         = "whitehall"
    allocated_storage            = 400
    instance_class               = "db.t4g.large"
    performance_insights_enabled = true
    project                      = "GOV.UK - Publishing"
    snapshot_identifier          = "whitehall-mysql-post-encryption"
    tags = {
      "used_by" = "whitehall"
    }
  }
}
