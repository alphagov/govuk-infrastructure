module "variable-set-integration" {
  source = "./variable-set"

  name = "common-integration"
  tfvars = {
    govuk_aws_state_bucket              = "govuk-terraform-steppingstone-integration"
    cluster_infrastructure_state_bucket = "govuk-terraform-integration"

    cluster_version               = "1.33"
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

    legacy_private_subnets = {
      a = { az = "eu-west-1a", cidr = "10.1.4.0/24", nat = true }
      b = { az = "eu-west-1b", cidr = "10.1.5.0/24", nat = true }
      c = { az = "eu-west-1c", cidr = "10.1.6.0/24", nat = true }

      rds_a = { az = "eu-west-1a", cidr = "10.1.10.0/24", nat = false }
      rds_b = { az = "eu-west-1b", cidr = "10.1.11.0/24", nat = false }
      rds_c = { az = "eu-west-1c", cidr = "10.1.12.0/24", nat = false }

      elasticache_a = { az = "eu-west-1a", cidr = "10.1.7.0/24", nat = false }
      elasticache_b = { az = "eu-west-1b", cidr = "10.1.8.0/24", nat = false }
      elasticache_c = { az = "eu-west-1c", cidr = "10.1.9.0/24", nat = false }

      elasticsearch_a = { az = "eu-west-1a", cidr = "10.1.16.0/24", nat = false }
      elasticsearch_b = { az = "eu-west-1b", cidr = "10.1.17.0/24", nat = false }
      elasticsearch_c = { az = "eu-west-1c", cidr = "10.1.18.0/24", nat = false }
    }

    govuk_environment = "integration"
    force_destroy     = true

    enable_kube_state_metrics = true

    enable_arm_workers = true
    enable_x86_workers = true

    main_workers_instance_types = ["m6i.4xlarge", "m6a.4xlarge", "m6i.2xlarge", "m6a.2xlarge"]

    publishing_service_domain = "integration.publishing.service.gov.uk"

    frontend_memcached_node_type = "cache.t4g.micro"

    # Non-production-only access is sufficient to access tools in this cluster.
    github_read_write_team = "alphagov:gov-uk"

    grafana_db_auto_pause       = true
    maintenance_window          = "Sun:04:00-Sun:06:00"
    rds_apply_immediately       = true
    rds_backup_retention_period = 1
    rds_skip_final_snapshot     = true

    secrets_recovery_window_in_days = 0

    desired_ha_replicas = 1

    ckan_s3_organogram_bucket = "datagovuk-integration-ckan-organogram"

    licensify_documentdb_instance_count       = 1
    licensify_backup_retention_period         = 1
    shared_documentdb_instance_count          = 1
    shared_documentdb_backup_retention_period = 1
  }
}

module "variable-set-chat-integration" {
  source = "./variable-set"

  name = "chat-integration"

  tfvars = {
    chat_redis_cluster_apply_immediately          = true
    chat_redis_cluster_automatic_failover_enabled = false
    chat_redis_cluster_multi_az_enabled           = false
    chat_redis_cluster_node_type                  = "cache.r6g.xlarge"
    chat_redis_cluster_num_cache_clusters         = "1"
  }
}

module "variable-set-opensearch-integration" {
  source = "./variable-set"

  name = "opensearch-integration"

  tfvars = {
    hosted_zone_name         = "chat"
    engine_version           = "2.13"
    security_options_enabled = true
    volume_type              = "gp3"
    throughput               = 250
    ebs_enabled              = true
    ebs_volume_size          = 90
    service                  = "chat"
    instance_type            = "r6g.2xlarge.search"
    instance_count           = 3
    dedicated_master_enabled = true
    dedicated_master_count   = 3
    dedicated_master_type    = "m6g.large.search"
    zone_awareness_enabled   = true
    test_opensearch_url      = "search-chat-engine-test-dofkxncldpkjd7huoyakdenpbi.eu-west-1.es.amazonaws.com"
  }
}

module "variable-set-rds-integration" {
  source = "./variable-set"

  name = "rds-integration"

  tfvars = {
    backup_retention_period = 1
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
          "rds.logical_replication" = {
            value        = 1,
            apply_method = "pending-reboot"
          }
          max_wal_senders = {
            value        = 35,
            apply_method = "pending-reboot"
          }
          max_logical_replication_workers = {
            value        = 20,
            apply_method = "pending-reboot"
          }
          max_worker_processes = {
            value        = 40,
            apply_method = "pending-reboot"
          }
        }
        engine_params_family         = "postgres13"
        name                         = "account-api"
        allocated_storage            = 100
        instance_class               = "db.t4g.medium"
        performance_insights_enabled = true
        project                      = "GOV.UK - Web"
        encryption_at_rest           = false
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
        encryption_at_rest           = false
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
        encryption_at_rest           = true
        snapshot_identifier          = "chat-postgres-post-encryption"
      }

      ckan = {
        engine         = "postgres"
        engine_version = "14.18"
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
        encryption_at_rest           = false
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
        encryption_at_rest           = false
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
        encryption_at_rest           = false
      }

      content_data_admin = {
        engine         = "postgres"
        engine_version = "14.18"
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
        encryption_at_rest           = false
      }

      content_data_api = {
        engine         = "postgres"
        engine_version = "13"
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
          "rds.logical_replication" = {
            value        = 1,
            apply_method = "pending-reboot"
          }
          max_wal_senders = {
            value        = 35,
            apply_method = "pending-reboot"
          }
          max_logical_replication_workers = {
            value        = 20,
            apply_method = "pending-reboot"
          }
          max_worker_processes = {
            value        = 40,
            apply_method = "pending-reboot"
          }
        }
        engine_params_family         = "postgres13"
        name                         = "blue-content-data-api-postgresql-primary"
        allocated_storage            = 500
        instance_class               = "db.m6g.large"
        performance_insights_enabled = false
        project                      = "GOV.UK - Publishing"
        encryption_at_rest           = false
      }

      content_publisher = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
          "rds.logical_replication" = {
            value        = 1,
            apply_method = "pending-reboot"
          }
          max_wal_senders = {
            value        = 35,
            apply_method = "pending-reboot"
          }
          max_logical_replication_workers = {
            value        = 20,
            apply_method = "pending-reboot"
          }
          max_worker_processes = {
            value        = 40,
            apply_method = "pending-reboot"
          }
        }
        engine_params_family         = "postgres13"
        name                         = "content-publisher"
        allocated_storage            = 100
        instance_class               = "db.t4g.small"
        performance_insights_enabled = false
        project                      = "GOV.UK - Publishing"
        encryption_at_rest           = false
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
        encryption_at_rest           = false
      }

      content_tagger = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
          "rds.logical_replication" = {
            value        = 1,
            apply_method = "pending-reboot"
          }
          max_wal_senders = {
            value        = 35,
            apply_method = "pending-reboot"
          }
          max_logical_replication_workers = {
            value        = 20,
            apply_method = "pending-reboot"
          }
          max_worker_processes = {
            value        = 40,
            apply_method = "pending-reboot"
          }
        }
        engine_params_family         = "postgres13"
        name                         = "content-tagger"
        allocated_storage            = 100
        instance_class               = "db.t4g.small"
        performance_insights_enabled = false
        project                      = "GOV.UK - Publishing"
        encryption_at_rest           = false
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
        encryption_at_rest           = false
      }

      email_alert_api = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
          "rds.logical_replication" = {
            value        = 1,
            apply_method = "pending-reboot"
          }
          max_wal_senders = {
            value        = 35,
            apply_method = "pending-reboot"
          }
          max_logical_replication_workers = {
            value        = 20,
            apply_method = "pending-reboot"
          }
          max_worker_processes = {
            value        = 40,
            apply_method = "pending-reboot"
          }
        }
        engine_params_family         = "postgres13"
        name                         = "email-alert-api"
        allocated_storage            = 1000
        instance_class               = "db.m6g.large"
        performance_insights_enabled = true
        project                      = "GOV.UK - Web"
        encryption_at_rest           = false
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
        engine_params_family         = "postgres14"
        name                         = "imminence"
        allocated_storage            = 100
        instance_class               = "db.t4g.medium"
        performance_insights_enabled = false
        project                      = "GOV.UK - Web"
        encryption_at_rest           = false
      }

      link_checker_api = {
        engine         = "postgres"
        engine_version = "14.18"
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
        encryption_at_rest           = false
      }

      local_links_manager = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
          "rds.logical_replication" = {
            value        = 1,
            apply_method = "pending-reboot"
          }
          max_wal_senders = {
            value        = 35,
            apply_method = "pending-reboot"
          }
          max_logical_replication_workers = {
            value        = 20,
            apply_method = "pending-reboot"
          }
          max_worker_processes = {
            value        = 40,
            apply_method = "pending-reboot"
          }
        }
        engine_params_family         = "postgres13"
        name                         = "local-links-manager"
        allocated_storage            = 100
        instance_class               = "db.t4g.small"
        performance_insights_enabled = false
        project                      = "GOV.UK - Web"
        encryption_at_rest           = false
      }

      locations_api = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
          "rds.logical_replication" = {
            value        = 1,
            apply_method = "pending-reboot"
          }
          max_wal_senders = {
            value        = 35,
            apply_method = "pending-reboot"
          }
          max_logical_replication_workers = {
            value        = 20,
            apply_method = "pending-reboot"
          }
          max_worker_processes = {
            value        = 40,
            apply_method = "pending-reboot"
          }
        }
        engine_params_family         = "postgres13"
        name                         = "locations-api"
        allocated_storage            = 1000
        instance_class               = "db.m6g.large"
        performance_insights_enabled = true
        project                      = "GOV.UK - Web"
        encryption_at_rest           = false
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
          "rds.logical_replication" = {
            value        = 1,
            apply_method = "pending-reboot"
          }
          max_wal_senders = {
            value        = 35,
            apply_method = "pending-reboot"
          }
          max_logical_replication_workers = {
            value        = 20,
            apply_method = "pending-reboot"
          }
          max_worker_processes = {
            value        = 40,
            apply_method = "pending-reboot"
          }
        }
        engine_params_family         = "postgres13"
        name                         = "publishing-api"
        allocated_storage            = 1000
        iops                         = 24000
        storage_throughput           = 1000
        instance_class               = "db.m6g.large"
        performance_insights_enabled = true
        project                      = "GOV.UK - Publishing"
        has_read_replica             = true
        encryption_at_rest           = false
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
        encryption_at_rest           = false
      }

      release = {
        engine         = "mysql"
        engine_version = "8.0"
        engine_params = {
          max_allowed_packet = { value = 1073741824 }
        }
        engine_params_family         = "mysql8.0"
        name                         = "release"
        allocated_storage            = 100
        instance_class               = "db.t4g.micro"
        performance_insights_enabled = false
        project                      = "GOV.UK - Infrastructure"
        encryption_at_rest           = false
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
        encryption_at_rest           = false
      }

      service_manual_publisher = {
        engine         = "postgres"
        engine_version = "14.18"
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
        encryption_at_rest           = false
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
        encryption_at_rest           = false
      }

      support_api = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
          "rds.logical_replication" = {
            value        = 1,
            apply_method = "pending-reboot"
          }
          max_wal_senders = {
            value        = 35,
            apply_method = "pending-reboot"
          }
          max_logical_replication_workers = {
            value        = 20,
            apply_method = "pending-reboot"
          }
          max_worker_processes = {
            value        = 40,
            apply_method = "pending-reboot"
          }
        }
        engine_params_family         = "postgres13"
        name                         = "support-api"
        allocated_storage            = 200
        instance_class               = "db.t4g.medium"
        performance_insights_enabled = true
        project                      = "GOV.UK - Publishing"
        encryption_at_rest           = false
      }

      transition = {
        engine         = "postgres"
        engine_version = "14.18"
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
        encryption_at_rest           = false
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
        encryption_at_rest           = false
      }
    }
  }
}

module "variable-set-amazonmq-integration" {
  source = "./variable-set"

  name = "amazonmq-integration"
  tfvars = {
    amazonmq_engine_version                       = "3.13"
    amazonmq_deployment_mode                      = "SINGLE_INSTANCE"
    amazonmq_maintenance_window_start_day_of_week = "MONDAY"
    amazonmq_maintenance_window_start_time_utc    = "07:00"
    amazonmq_host_instance_type                   = "mq.m5.large"

    amazonmq_govuk_chat_retry_message_ttl = 300000
  }
}

module "variable-set-elasticache-integration" {
  source = "./variable-set"

  name = "elasticache-integration"

  # The configuration of the "caches" variable is in
  # "govuk-infrastructure/terraform/deployments/elasticache/variables.tf".
  # Only the name and description are required, the rest of the parameters
  # are optional, with their defaults as follows:
  #   name                       = required
  #   description                = required
  #   num_cache_clusters         = optional (default = "1")
  #   node_type                  = optional (default = "cache.t4g.small")
  #   automatic_failover_enabled = optional (default = false)
  #   multi_az_enabled           = optional (default = false)
  #   engine                     = optional (default = "valkey")
  #   engine_version             = optional (default = "8.0")
  #   family                     = optional (default = "valkey8")
  # If any further parameters need to be modified in the
  # elasticache parameter group, they need to be configured here
  # for them to take effect, otherwise the values will be ignored:
  #   parameters = {
  #     maxmemory-policy = optional (default = "noeviction")
  #   }

  tfvars = {
    caches = {}
  }
}

module "variable-set-elasticsearch-integration" {
  source = "./variable-set"

  name = "elasticsearch-integration"

  tfvars = {
    ebs = {
      volume_size      = 314
      volume_type      = "gp3"
      throughput       = 250
      provisioned_iops = 3000
    }
    engine_version         = "6.7"
    zone_awareness_enabled = true

    instance_count = 3
    instance_type  = "r7i.xlarge.elasticsearch"

    dedicated_master = {
      instance_count = 3
      instance_type  = "c7i.xlarge.elasticsearch"
    }

    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"

    stackname = "blue"

    elasticsearch6_manual_snapshot_bucket_arns = [
      "arn:aws:s3:::govuk-staging-elasticsearch6-manual-snapshots",
      "arn:aws:s3:::govuk-integration-elasticsearch6-manual-snapshots"
    ]

    encryption_at_rest = false
  }
}
