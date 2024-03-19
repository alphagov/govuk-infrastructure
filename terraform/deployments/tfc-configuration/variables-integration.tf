module "variable-set-integration" {
  source = "./variable-set"

  name = "common-integration"
  tfvars = {
    govuk_aws_state_bucket              = "govuk-terraform-steppingstone-integration"
    cluster_infrastructure_state_bucket = "govuk-terraform-integration"

    cluster_version               = 1.29
    cluster_log_retention_in_days = 7

    vpc_cidr = "10.1.0.0/16"

    eks_control_plane_subnets = {
      a = { az = "eu-west-1a", cidr = "10.1.19.0/28" }
      b = { az = "eu-west-1b", cidr = "10.1.19.16/28" }
      c = { az = "eu-west-1c", cidr = "10.1.19.32/28" }
    }

    eks_public_subnets = {
      a = { az = "eu-west-1a", cidr = "10.1.20.0/24" }
      b = { az = "eu-west-1b", cidr = "10.1.21.0/24" }
      c = { az = "eu-west-1c", cidr = "10.1.22.0/24" }
    }

    eks_private_subnets = {
      a = { az = "eu-west-1a", cidr = "10.1.24.0/22" }
      b = { az = "eu-west-1b", cidr = "10.1.28.0/22" }
      c = { az = "eu-west-1c", cidr = "10.1.32.0/22" }
    }

    govuk_environment = "integration"
    force_destroy     = true

    publishing_service_domain = "integration.publishing.service.gov.uk"

    frontend_memcached_node_type   = "cache.t4g.micro"
    shared_redis_cluster_node_type = "cache.m6g.large"

    # Non-production-only access is sufficient to access tools in this cluster.
    github_read_write_team = "alphagov:gov-uk"

    grafana_db_auto_pause       = true
    maintenance_window          = "Sun:04:00-Sun:06:00"
    rds_apply_immediately       = true
    rds_backup_retention_period = 1
    rds_skip_final_snapshot     = true

    secrets_recovery_window_in_days = 0

    argo_redis_ha       = false
    desired_ha_replicas = 1

    ckan_s3_organogram_bucket = "datagovuk-integration-ckan-organogram"
  }
}

module "variable-set-rds-integration" {
  source = "./variable-set"

  name = "rds-integration"

  tfvars = {
    backup_retention_period = 0
    skip_final_snapshot     = true
    multi_az                = false

    databases = {
      account_api = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family = "postgres13"

        name              = "account-api"
        allocated_storage = 100
        instance_class    = "db.t4g.medium"

        performance_insights_enabled = true

        freestoragespace_threshold = 10737418240
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
        engine_params_family = "postgres14"

        name              = "authenticating-proxy"
        allocated_storage = 100
        instance_class    = "db.t4g.micro"

        performance_insights_enabled = false

        freestoragespace_threshold = 10737418240
      }

      ckan = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family = "postgres13"

        name              = "ckan"
        allocated_storage = 1000
        instance_class    = "db.m6g.large"

        performance_insights_enabled = true

        freestoragespace_threshold = 10737418240
      }

      collections_publisher = {
        engine         = "mysql"
        engine_version = "8.0"
        engine_params = {
          max_allowed_packet = { value = 1073741824 }
        }
        engine_params_family = "mysql8.0"

        name              = "collections-publisher"
        allocated_storage = 100
        instance_class    = "db.t4g.micro"

        performance_insights_enabled = false

        freestoragespace_threshold = 10737418240
      }

      contacts_admin = {
        engine         = "mysql"
        engine_version = "8.0"
        engine_params = {
          max_allowed_packet = { value = 1073741824 }
        }
        engine_params_family = "mysql8.0"

        name              = "contacts-admin"
        allocated_storage = 100
        instance_class    = "db.t4g.small"

        performance_insights_enabled = false

        freestoragespace_threshold = 10737418240
      }

      content_data_admin = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family = "postgres13"

        name              = "content-data-admin"
        allocated_storage = 100
        instance_class    = "db.t4g.micro"

        performance_insights_enabled = false

        freestoragespace_threshold = 10737418240
      }

      content_data_api = {
        engine         = "postgres"
        engine_version = "13.13"
        engine_params = {
          work_mem                             = { value = "GREATEST({DBInstanceClassMemory/${1024 * 16}},65536)" }
          autovacuum_max_workers               = { value = 1, apply_method = "pending-reboot" }
          maintenance_work_mem                 = { value = "GREATEST({DBInstanceClassMemory/${1024 * 3}},65536)" }
          "rds.force_autovacuum_logging_level" = { value = "log" }
          log_autovacuum_min_duration          = { value = 10000 }
          log_min_duration_statement           = { value = "10000" }
          log_statement                        = { value = "all" }
          deadlock_timeout                     = { value = 2500 }
          log_lock_waits                       = { value = 1 }
        }
        engine_params_family = "postgres13"

        name              = "blue-content-data-api-postgresql-primary"
        allocated_storage = 400
        instance_class    = "db.m6g.large"

        performance_insights_enabled = false

        freestoragespace_threshold = 536870912000
      }

      content_publisher = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family = "postgres13"

        name              = "content-publisher"
        allocated_storage = 100
        instance_class    = "db.t4g.small"

        performance_insights_enabled = false

        freestoragespace_threshold = 10737418240
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
        engine_params_family = "postgres14"

        name              = "content-store"
        allocated_storage = 500
        instance_class    = "db.m6g.large"

        performance_insights_enabled = true

        freestoragespace_threshold = 10737418240
      }

      content_tagger = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family = "postgres13"

        name              = "content-tagger"
        allocated_storage = 100
        instance_class    = "db.t4g.small"

        performance_insights_enabled = false

        freestoragespace_threshold = 10737418240
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
        engine_params_family = "postgres14"

        name              = "draft-content-store"
        allocated_storage = 500
        instance_class    = "db.m6g.large"

        performance_insights_enabled = true

        freestoragespace_threshold = 10737418240
      }

      email_alert_api = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family = "postgres13"

        name              = "email-alert-api"
        allocated_storage = 1000
        instance_class    = "db.m6g.large"

        performance_insights_enabled = true

        freestoragespace_threshold = 10737418240
      }

      imminence = {
        engine         = "postgres"
        engine_version = "14"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
          password_encryption        = { value = "md5" }
        }
        engine_params_family = "postgres14"

        name              = "imminence"
        allocated_storage = 100
        instance_class    = "db.t4g.medium"

        performance_insights_enabled = false

        freestoragespace_threshold = 10737418240
      }

      link_checker_api = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family = "postgres13"

        name              = "link-checker-api"
        allocated_storage = 100
        instance_class    = "db.t4g.medium"

        performance_insights_enabled = false

        freestoragespace_threshold = 10737418240
      }

      local_links_manager = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family = "postgres13"

        name              = "local-links-manager"
        allocated_storage = 100
        instance_class    = "db.t4g.small"

        performance_insights_enabled = false

        freestoragespace_threshold = 10737418240
      }

      locations_api = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family = "postgres13"

        name              = "locations-api"
        allocated_storage = 1000
        instance_class    = "db.m6g.large"

        performance_insights_enabled = true

        freestoragespace_threshold = 10737418240
      }

      publishing_api = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
          checkpoint_timeout         = { value = 3600 }
          max_wal_size               = { value = 4096 }
          synchronous_commit         = { value = "off" }
        }
        engine_params_family = "postgres13"

        name              = "publishing-api"
        allocated_storage = 1000
        instance_class    = "db.m6g.large"

        performance_insights_enabled = true

        freestoragespace_threshold = 10737418240
      }

      release = {
        engine         = "mysql"
        engine_version = "8.0"
        engine_params = {
          max_allowed_packet = { value = 1073741824 }
        }
        engine_params_family = "mysql8.0"

        name              = "release"
        allocated_storage = 100
        instance_class    = "db.t4g.micro"

        performance_insights_enabled = false

        freestoragespace_threshold = 10737418240
      }

      search_admin = {
        engine         = "mysql"
        engine_version = "8.0"
        engine_params = {
          max_allowed_packet = { value = 1073741824 }
        }
        engine_params_family = "mysql8.0"

        name              = "search-admin"
        allocated_storage = 100
        instance_class    = "db.t4g.micro"

        performance_insights_enabled = false

        freestoragespace_threshold = 10737418240
      }

      service_manual_publisher = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family = "postgres13"

        name              = "service-manual-publisher"
        allocated_storage = 100
        instance_class    = "db.t4g.small"

        performance_insights_enabled = false

        freestoragespace_threshold = 10737418240
      }

      signon = {
        engine         = "mysql"
        engine_version = "8.0"
        engine_params = {
          max_allowed_packet = { value = 1073741824 }
        }
        engine_params_family = "mysql8.0"

        name              = "signon"
        allocated_storage = 100
        instance_class    = "db.t4g.medium"

        performance_insights_enabled = true

        freestoragespace_threshold = 10737418240
      }

      support_api = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family = "postgres13"

        name              = "support-api"
        allocated_storage = 200
        instance_class    = "db.t4g.medium"

        performance_insights_enabled = true

        freestoragespace_threshold = 10737418240
      }

      whitehall = {
        engine         = "mysql"
        engine_version = "8.0"
        engine_params = {
          max_allowed_packet = { value = 1073741824 }
        }
        engine_params_family = "mysql8.0"

        name              = "whitehall"
        allocated_storage = 400
        instance_class    = "db.t4g.large"

        performance_insights_enabled = true

        freestoragespace_threshold = 10737418240
      }
    }
  }
}
