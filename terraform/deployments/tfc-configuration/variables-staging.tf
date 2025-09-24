module "variable-set-staging" {
  source = "./variable-set"

  name = "common-staging"
  tfvars = {
    govuk_aws_state_bucket              = "govuk-terraform-steppingstone-staging"
    cluster_infrastructure_state_bucket = "govuk-terraform-staging"

    cluster_version               = "1.33"
    cluster_log_retention_in_days = 7

    vpc_cidr = "10.12.0.0/16"

    eks_control_plane_subnets = {
      a = { az = "eu-west-1a", cidr = "10.12.19.0/28" }
      b = { az = "eu-west-1b", cidr = "10.12.19.16/28" }
      c = { az = "eu-west-1c", cidr = "10.12.19.32/28" }
    }

    eks_public_subnets = {
      a = { az = "eu-west-1a", cidr = "10.12.20.0/24" }
      b = { az = "eu-west-1b", cidr = "10.12.21.0/24" }
      c = { az = "eu-west-1c", cidr = "10.12.22.0/24" }
    }

    eks_private_subnets = {
      a = { az = "eu-west-1a", cidr = "10.12.24.0/22" }
      b = { az = "eu-west-1b", cidr = "10.12.28.0/22" }
      c = { az = "eu-west-1c", cidr = "10.12.32.0/22" }
    }

    legacy_private_subnets = {
      a = { az = "eu-west-1a", cidr = "10.12.4.0/24", nat = true }
      b = { az = "eu-west-1b", cidr = "10.12.5.0/24", nat = true }
      c = { az = "eu-west-1c", cidr = "10.12.6.0/24", nat = true }

      rds_a = { az = "eu-west-1a", cidr = "10.12.10.0/24", nat = false }
      rds_b = { az = "eu-west-1b", cidr = "10.12.11.0/24", nat = false }
      rds_c = { az = "eu-west-1c", cidr = "10.12.12.0/24", nat = false }

      elasticache_a = { az = "eu-west-1a", cidr = "10.12.7.0/24", nat = false }
      elasticache_b = { az = "eu-west-1b", cidr = "10.12.8.0/24", nat = false }
      elasticache_c = { az = "eu-west-1c", cidr = "10.12.9.0/24", nat = false }

      elasticsearch_a = { az = "eu-west-1a", cidr = "10.12.16.0/24", nat = false }
      elasticsearch_b = { az = "eu-west-1b", cidr = "10.12.17.0/24", nat = false }
      elasticsearch_c = { az = "eu-west-1c", cidr = "10.12.18.0/24", nat = false }
    }

    govuk_environment = "staging"

    enable_kube_state_metrics = false

    enable_arm_workers = true
    enable_x86_workers = true

    main_workers_instance_types = ["m6i.4xlarge", "m6a.4xlarge", "m6i.2xlarge", "m6a.2xlarge"]

    publishing_service_domain = "staging.publishing.service.gov.uk"

    frontend_memcached_node_type = "cache.t4g.medium"

    desired_ha_replicas         = 2
    rds_backup_retention_period = 1

    ckan_s3_organogram_bucket = "datagovuk-staging-ckan-organogram"

    licensify_documentdb_instance_count       = 1
    licensify_backup_retention_period         = 1
    shared_documentdb_instance_count          = 1
    shared_documentdb_backup_retention_period = 1
  }
}

module "variable-set-cloudfront-staging" {
  source = "./variable-set"

  name = "cloudfront-staging"
  tfvars = {
    aws_region                             = "eu-west-1"
    cloudfront_enable                      = true
    cloudfront_create                      = 1
    logging_bucket                         = "govuk-staging-aws-logging.s3.amazonaws.com"
    assets_certificate_arn                 = "arn:aws:acm:us-east-1:696911096973:certificate/642e34ef-71e2-439d-99f7-e79baf9ed482"
    www_certificate_arn                    = "arn:aws:acm:us-east-1:696911096973:certificate/642e34ef-71e2-439d-99f7-e79baf9ed482"
    cloudfront_assets_distribution_aliases = ["assets.staging.publishing.service.gov.uk"]
    cloudfront_www_distribution_aliases    = ["www.staging.publishing.service.gov.uk"]
    cloudfront_web_acl_default_allow       = false
    cloudfront_web_acl_allow_gds_ips       = true
    origin_www_domain                      = "www-origin.eks.staging.govuk.digital"
    origin_www_id                          = "WWW Origin"
    origin_assets_domain                   = "assets-origin.eks.staging.govuk.digital"
    origin_assets_id                       = "WWW Assets"
    origin_notify_domain                   = "d2v0bxdqgxvh58.cloudfront.net"
    origin_notify_id                       = "notify alerts"
  }
}

module "variable-set-chat-staging" {
  source = "./variable-set"

  name = "chat-staging"

  tfvars = {
    chat_redis_cluster_apply_immediately          = true
    chat_redis_cluster_automatic_failover_enabled = false
    chat_redis_cluster_multi_az_enabled           = false
    chat_redis_cluster_node_type                  = "cache.r6g.xlarge"
    chat_redis_cluster_num_cache_clusters         = "1"
  }
}

module "variable-set-opensearch-staging" {
  source = "./variable-set"

  name = "opensearch-staging"

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
  }
}

module "variable-set-rds-staging" {
  source = "./variable-set"

  name = "rds-staging"
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
        snapshot_identifier          = "chat-postgres-post-encryption"
        encryption_at_rest           = true
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
        allocated_storage            = 1024
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
        instance_class               = "db.m6g.xlarge"
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
        instance_class               = "db.m7g.2xlarge"
        performance_insights_enabled = true
        project                      = "GOV.UK - Publishing"
        has_read_replica             = true
        encryption_at_rest           = false
      }

      publisher = {
        engine         = "postgres"
        engine_version = "17"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family         = "postgres17"
        name                         = "publisher"
        allocated_storage            = 100
        instance_class               = "db.t4g.micro"
        performance_insights_enabled = false
        project                      = "GOV.UK - Publishing"
        deletion_protection          = false
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
        instance_class               = "db.t4g.micro"
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
        instance_class               = "db.m6g.large"
        performance_insights_enabled = true
        project                      = "GOV.UK - Publishing"
        encryption_at_rest           = false
      }
    }
  }
}

module "variable-set-amazonmq-staging" {
  source = "./variable-set"

  name = "amazonmq-staging"
  tfvars = {
    amazonmq_engine_version                       = "3.13"
    amazonmq_deployment_mode                      = "SINGLE_INSTANCE"
    amazonmq_maintenance_window_start_day_of_week = "MONDAY"
    amazonmq_maintenance_window_start_time_utc    = "07:00"
    amazonmq_host_instance_type                   = "mq.m5.large"

    amazonmq_govuk_chat_retry_message_ttl = 300000
  }
}

module "variable-set-elasticache-staging" {
  source = "./variable-set"

  name = "elasticache-staging"

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

module "variable-set-elasticsearch-staging" {
  source = "./variable-set"

  name = "elasticsearch-staging"

  tfvars = {
    ebs = {
      volume_size      = 85
      volume_type      = "gp3"
      throughput       = 125
      provisioned_iops = 3000
    }

    govuk_environment      = "staging"
    engine_version         = "6.7"
    zone_awareness_enabled = true

    instance_count = 3
    instance_type  = "r5.2xlarge.elasticsearch"

    dedicated_master = {
      instance_count = 3
      instance_type  = "c5.large.elasticsearch"
    }

    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"

    stackname = "blue"

    elasticsearch6_manual_snapshot_bucket_arns = [
      "arn:aws:s3:::govuk-production-elasticsearch6-manual-snapshots",
      "arn:aws:s3:::govuk-staging-elasticsearch6-manual-snapshots"
    ]

    encryption_at_rest = true
  }
}
