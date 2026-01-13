module "variable-set-production" {
  source = "./variable-set"

  name = "common-production"
  tfvars = {
    govuk_aws_state_bucket              = "govuk-terraform-steppingstone-production"
    cluster_infrastructure_state_bucket = "govuk-terraform-production"

    cluster_version               = "1.33" # Don't forget to change this in variables-test.tf too
    cluster_log_retention_in_days = 7

    vpc_cidr = "10.13.0.0/16"

    eks_control_plane_subnets = {
      a = { az = "eu-west-1a", cidr = "10.13.19.0/28" }
      b = { az = "eu-west-1b", cidr = "10.13.19.16/28" }
      c = { az = "eu-west-1c", cidr = "10.13.19.32/28" }
    }

    eks_public_subnets = {
      a = { az = "eu-west-1a", cidr = "10.13.20.0/24" }
      b = { az = "eu-west-1b", cidr = "10.13.21.0/24" }
      c = { az = "eu-west-1c", cidr = "10.13.22.0/24" }
    }

    eks_private_subnets = {
      a = { az = "eu-west-1a", cidr = "10.13.24.0/22" }
      b = { az = "eu-west-1b", cidr = "10.13.28.0/22" }
      c = { az = "eu-west-1c", cidr = "10.13.32.0/22" }
    }

    legacy_private_subnets = {
      a = { az = "eu-west-1a", cidr = "10.13.4.0/24", nat = true }
      b = { az = "eu-west-1b", cidr = "10.13.5.0/24", nat = true }
      c = { az = "eu-west-1c", cidr = "10.13.6.0/24", nat = true }

      rds_a = { az = "eu-west-1a", cidr = "10.13.10.0/24", nat = false }
      rds_b = { az = "eu-west-1b", cidr = "10.13.11.0/24", nat = false }
      rds_c = { az = "eu-west-1c", cidr = "10.13.12.0/24", nat = false }

      elasticache_a = { az = "eu-west-1a", cidr = "10.13.7.0/24", nat = false }
      elasticache_b = { az = "eu-west-1b", cidr = "10.13.8.0/24", nat = false }
      elasticache_c = { az = "eu-west-1c", cidr = "10.13.9.0/24", nat = false }

      elasticsearch_a = { az = "eu-west-1a", cidr = "10.13.16.0/24", nat = false }
      elasticsearch_b = { az = "eu-west-1b", cidr = "10.13.17.0/24", nat = false }
      elasticsearch_c = { az = "eu-west-1c", cidr = "10.13.18.0/24", nat = false }
    }

    govuk_environment = "production"

    enable_kube_state_metrics = false

    enable_arm_workers_blue  = false
    enable_arm_workers_green = true
    enable_x86_workers       = false

    publishing_service_domain = "publishing.service.gov.uk"


    frontend_memcached_node_type = "cache.r6g.large"

    ckan_s3_organogram_bucket = "datagovuk-production-ckan-organogram"

    shared_documentdb_identifier_suffix = "-1"
  }
}

module "variable-set-cloudfront-production" {
  source = "./variable-set"

  name = "cloudfront-production"
  tfvars = {
    aws_region                             = "eu-west-1"
    cloudfront_enable                      = true
    cloudfront_create                      = 1
    logging_bucket                         = "govuk-production-aws-logging.s3.amazonaws.com"
    assets_certificate_arn                 = "arn:aws:acm:us-east-1:172025368201:certificate/ea27535c-f48a-4755-b6ca-c048c880e02d"
    cloudfront_assets_distribution_aliases = ["assets.publishing.service.gov.uk"]
    www_certificate_arn                    = "arn:aws:acm:us-east-1:172025368201:certificate/f2932d95-b83e-4627-b080-90aeea3c5b00"
    cloudfront_www_distribution_aliases    = ["www.gov.uk"]
    cloudfront_web_acl_default_allow       = true
    cloudfront_web_acl_allow_gds_ips       = false
    origin_www_domain                      = "www-origin.eks.production.govuk.digital"
    origin_www_id                          = "WWW Origin"
    origin_assets_domain                   = "assets-origin.eks.production.govuk.digital"
    origin_assets_id                       = "WWW Assets"
    origin_notify_domain                   = "d35wa574vjcy9s.cloudfront.net"
    origin_notify_id                       = "notify alerts"
  }
}

module "variable-set-ecr-production" {
  source = "./variable-set"

  name = "ecr-production"
  tfvars = {
    emails = ["govuk-platform-engineering+ecr-inspector@digital.cabinet-office.gov.uk"]

    puller_arns = [
      "arn:aws:iam::172025368201:root", # Production
      "arn:aws:iam::696911096973:root", # Staging
      "arn:aws:iam::210287912431:root", # Integration
      "arn:aws:iam::430354129336:root", # Test
    ]
  }
}

module "variable-set-chat-production" {
  source = "./variable-set"

  name = "chat-production"

  tfvars = {
    chat_redis_cluster_apply_immediately          = false
    chat_redis_cluster_automatic_failover_enabled = true
    chat_redis_cluster_multi_az_enabled           = true
    chat_redis_cluster_node_type                  = "cache.r6g.xlarge"
    chat_redis_cluster_num_cache_clusters         = "2"
  }
}

module "variable-set-opensearch-production" {
  source = "./variable-set"

  name = "opensearch-production"

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

module "variable-set-rds-production" {
  source = "./variable-set"

  name = "rds-production"
  tfvars = {
    backup_retention_period = 7
    skip_final_snapshot     = false
    multi_az                = true

    databases = {
      account_api = {
        engine         = "postgres"
        engine_version = "14.19"
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
        encryption_at_rest           = false
        prepare_to_launch_new_db     = false
        backup_window                = "20:00-20:30"
        maintenance_window           = "Sat:00:00-Sat:02:00"
        auto_minor_version_upgrade   = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      authenticating_proxy = {
        engine         = "postgres"
        engine_version = "14.19"
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
        instance_class               = "db.t4g.small"
        performance_insights_enabled = false
        project                      = "GOV.UK - Publishing"
        encryption_at_rest           = false
        prepare_to_launch_new_db     = false
        backup_window                = "20:00-20:30"
        maintenance_window           = "Sat:00:00-Sat:02:00"
        auto_minor_version_upgrade   = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      chat = {
        engine         = "postgres"
        engine_version = "16.10"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family         = "postgres16"
        name                         = "chat"
        allocated_storage            = 100
        instance_class               = "db.m6g.large"
        performance_insights_enabled = false
        project                      = "GOV.UK - AI"
        snapshot_identifier          = "chat-postgres-post-encryption"
        encryption_at_rest           = true
        prepare_to_launch_new_db     = false
        launch_new_db                = false
        isolate                      = false
        cname_point_to_new_instance  = false
        new_db_deletion_protection   = false
      }

      ckan = {
        engine         = "postgres"
        engine_version = "14.19"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family         = "postgres14"
        name                         = "ckan"
        allocated_storage            = 1250
        instance_class               = "db.m6g.2xlarge"
        performance_insights_enabled = true
        project                      = "GOV.UK - DGU"
        encryption_at_rest           = false
        backup_window                = "08:00-08:30"
        auto_minor_version_upgrade   = false
        prepare_to_launch_new_db     = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      collections_publisher = {
        engine         = "mysql"
        engine_version = "8.0.43"
        engine_params = {
          max_allowed_packet = { value = 1073741824 }
        }
        engine_params_family         = "mysql8.0"
        name                         = "collections-publisher"
        allocated_storage            = 100
        instance_class               = "db.t4g.medium"
        performance_insights_enabled = true
        project                      = "GOV.UK - Publishing"
        encryption_at_rest           = false
        prepare_to_launch_new_db     = false
        backup_window                = "20:00-20:30"
        maintenance_window           = "Sat:00:00-Sat:02:00"
        auto_minor_version_upgrade   = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      content_block_manager = {
        engine                      = "postgres"
        engine_version              = "17.6"
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
        prepare_to_launch_new_db     = false
        backup_window                = "20:00-20:30"
        maintenance_window           = "Sat:00:00-Sat:02:00"
        auto_minor_version_upgrade   = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      content_data_admin = {
        engine         = "postgres"
        engine_version = "14.19"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family         = "postgres14"
        name                         = "content-data-admin"
        allocated_storage            = 100
        instance_class               = "db.t4g.medium"
        performance_insights_enabled = true
        project                      = "GOV.UK - Publishing"
        encryption_at_rest           = false
        backup_window                = "08:00-08:30"
        auto_minor_version_upgrade   = false
        prepare_to_launch_new_db     = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      content_data_api = {
        engine         = "postgres"
        engine_version = "14.19"
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
        name                         = "blue-content-data-api-postgresql-primary"
        new_name                     = "content-data-api"
        allocated_storage            = 1024
        instance_class               = "db.m6g.large"
        performance_insights_enabled = false
        project                      = "GOV.UK - Publishing"
        encryption_at_rest           = false
        prepare_to_launch_new_db     = false
        backup_window                = "20:00-20:30"
        maintenance_window           = "Sat:00:00-Sat:02:00"
        auto_minor_version_upgrade   = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      content_store = {
        engine         = "postgres"
        engine_version = "14.19"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family         = "postgres14"
        name                         = "content-store"
        allocated_storage            = 1000
        instance_class               = "db.m6g.2xlarge"
        performance_insights_enabled = true
        project                      = "GOV.UK - Publishing"
        encryption_at_rest           = false
        prepare_to_launch_new_db     = false
        backup_window                = "20:00-20:30"
        maintenance_window           = "Sat:00:00-Sat:02:00"
        auto_minor_version_upgrade   = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      content_tagger = {
        engine         = "postgres"
        engine_version = "14.19"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family         = "postgres14"
        name                         = "content-tagger"
        allocated_storage            = 100
        instance_class               = "db.t4g.medium"
        performance_insights_enabled = true
        project                      = "GOV.UK - Publishing"
        encryption_at_rest           = false
        prepare_to_launch_new_db     = false
        backup_window                = "20:00-20:30"
        maintenance_window           = "Sat:00:00-Sat:02:00"
        auto_minor_version_upgrade   = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      draft_content_store = {
        engine         = "postgres"
        engine_version = "14.19"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family         = "postgres14"
        name                         = "draft-content-store"
        allocated_storage            = 1000
        instance_class               = "db.m6g.2xlarge"
        performance_insights_enabled = true
        project                      = "GOV.UK - Publishing"
        encryption_at_rest           = false
        prepare_to_launch_new_db     = false
        backup_window                = "20:00-20:30"
        maintenance_window           = "Sat:00:00-Sat:02:00"
        auto_minor_version_upgrade   = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      email_alert_api = {
        engine         = "postgres"
        engine_version = "14.19"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family         = "postgres14"
        name                         = "email-alert-api"
        allocated_storage            = 4500
        instance_class               = "db.m7g.2xlarge"
        performance_insights_enabled = true
        project                      = "GOV.UK - Web"
        encryption_at_rest           = false
        prepare_to_launch_new_db     = false
        backup_window                = "20:00-20:30"
        maintenance_window           = "Sat:00:00-Sat:02:00"
        auto_minor_version_upgrade   = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      imminence = {
        engine         = "postgres"
        engine_version = "14.19"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
          password_encryption        = { value = "md5" }
        }
        engine_params_family         = "postgres14"
        name                         = "imminence"
        new_name                     = "places-manager"
        allocated_storage            = 100
        instance_class               = "db.m6g.large"
        performance_insights_enabled = true
        project                      = "GOV.UK - Web"
        encryption_at_rest           = false
        prepare_to_launch_new_db     = false
        backup_window                = "20:00-20:30"
        maintenance_window           = "Sat:00:00-Sat:02:00"
        auto_minor_version_upgrade   = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      link_checker_api = {
        engine         = "postgres"
        engine_version = "14.19"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family         = "postgres14"
        name                         = "link-checker-api"
        allocated_storage            = 100
        instance_class               = "db.t4g.large"
        performance_insights_enabled = true
        project                      = "GOV.UK - Publishing"
        maintenance_window           = "Mon:00:00-Mon:01:00"
        encryption_at_rest           = false
        backup_window                = "08:00-08:30"
        auto_minor_version_upgrade   = false
        prepare_to_launch_new_db     = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      local_links_manager = {
        engine         = "postgres"
        engine_version = "14.19"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family         = "postgres14"
        name                         = "local-links-manager"
        allocated_storage            = 100
        instance_class               = "db.t4g.medium"
        performance_insights_enabled = true
        project                      = "GOV.UK - Web"
        encryption_at_rest           = false
        prepare_to_launch_new_db     = false
        backup_window                = "20:00-20:30"
        maintenance_window           = "Sat:00:00-Sat:02:00"
        auto_minor_version_upgrade   = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      locations_api = {
        engine         = "postgres"
        engine_version = "14.19"
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
        encryption_at_rest           = false
        prepare_to_launch_new_db     = false
        backup_window                = "20:00-20:30"
        maintenance_window           = "Sat:00:00-Sat:02:00"
        auto_minor_version_upgrade   = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      publishing_api = {
        engine                    = "postgres"
        engine_version            = "17.6"
        replica_engine_version    = "17.6"
        replica_apply_immediately = false
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family         = "postgres17"
        name                         = "publishing-api"
        allocated_storage            = 1000
        iops                         = 24000
        storage_throughput           = 1000
        instance_class               = "db.m6g.4xlarge"
        performance_insights_enabled = true
        project                      = "GOV.UK - Publishing"
        has_read_replica             = true
        encryption_at_rest           = false
        prepare_to_launch_new_db     = false
        backup_window                = "20:00-20:30"
        maintenance_window           = "Sat:00:00-Sat:02:00"
        auto_minor_version_upgrade   = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        launch_new_replica           = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      publisher = {
        engine         = "postgres"
        engine_version = "17.6"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family         = "postgres17"
        name                         = "publisher"
        allocated_storage            = 100
        instance_class               = "db.t4g.medium"
        performance_insights_enabled = true
        project                      = "GOV.UK - Publishing"
        encryption_at_rest           = false
        prepare_to_launch_new_db     = false
        backup_window                = "20:00-20:30"
        maintenance_window           = "Sat:00:00-Sat:02:00"
        auto_minor_version_upgrade   = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      release = {
        engine         = "mysql"
        engine_version = "8.0.43"
        engine_params = {
          max_allowed_packet = { value = 1073741824 }
        }
        engine_params_family         = "mysql8.0"
        name                         = "release"
        allocated_storage            = 100
        instance_class               = "db.t4g.small"
        performance_insights_enabled = false
        project                      = "GOV.UK - Infrastructure"
        encryption_at_rest           = false
        backup_window                = "08:00-08:30"
        auto_minor_version_upgrade   = false
        prepare_to_launch_new_db     = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      search_admin = {
        engine         = "mysql"
        engine_version = "8.0.43"
        engine_params = {
          max_allowed_packet = { value = 1073741824 }
        }
        engine_params_family         = "mysql8.0"
        name                         = "search-admin"
        allocated_storage            = 100
        instance_class               = "db.t4g.small"
        performance_insights_enabled = false
        project                      = "GOV.UK - Search"
        encryption_at_rest           = false
        backup_window                = "08:00-08:30"
        auto_minor_version_upgrade   = false
        prepare_to_launch_new_db     = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      service_manual_publisher = {
        engine         = "postgres"
        engine_version = "14.19"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family         = "postgres14"
        name                         = "service-manual-publisher"
        allocated_storage            = 100
        instance_class               = "db.t4g.medium"
        performance_insights_enabled = true
        project                      = "GOV.UK - Publishing"
        encryption_at_rest           = false
        backup_window                = "08:00-08:30"
        auto_minor_version_upgrade   = false
        prepare_to_launch_new_db     = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      signon = {
        engine         = "mysql"
        engine_version = "8.0.43"
        engine_params = {
          max_allowed_packet = { value = 1073741824 }
        }
        engine_params_family         = "mysql8.0"
        name                         = "signon"
        allocated_storage            = 100
        instance_class               = "db.t4g.large"
        performance_insights_enabled = true
        project                      = "GOV.UK - Publishing"
        encryption_at_rest           = false
        prepare_to_launch_new_db     = false
        backup_window                = "20:00-20:30"
        maintenance_window           = "Sat:00:00-Sat:02:00"
        auto_minor_version_upgrade   = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      support_api = {
        engine         = "postgres"
        engine_version = "14.19"
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
        encryption_at_rest           = false
        prepare_to_launch_new_db     = false
        backup_window                = "20:00-20:30"
        maintenance_window           = "Sat:00:00-Sat:02:00"
        auto_minor_version_upgrade   = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      transition = {
        engine         = "postgres"
        engine_version = "14.19"
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
        prepare_to_launch_new_db     = false
        backup_window                = "20:00-20:30"
        maintenance_window           = "Sat:00:00-Sat:02:00"
        auto_minor_version_upgrade   = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }

      whitehall = {
        engine         = "mysql"
        engine_version = "8.0.43"
        engine_params = {
          max_allowed_packet = { value = 1073741824 }
        }
        engine_params_family         = "mysql8.0"
        name                         = "whitehall"
        allocated_storage            = 400
        iops                         = 12000
        storage_throughput           = 500
        instance_class               = "db.m7g.xlarge"
        performance_insights_enabled = true
        project                      = "GOV.UK - Publishing"
        encryption_at_rest           = false
        prepare_to_launch_new_db     = false
        backup_window                = "20:00-20:30"
        maintenance_window           = "Sat:00:00-Sat:02:00"
        auto_minor_version_upgrade   = false
        isolate                      = true
        launch_new_db                = true
        new_db_deletion_protection   = true
        cname_point_to_new_instance  = true
        deletion_protection          = false
        destroy_old_instance         = true
      }
    }
  }
}

module "variable-set-amazonmq-production" {
  source = "./variable-set"

  name = "amazonmq-production"
  tfvars = {
    amazonmq_engine_version                       = "3.13"
    amazonmq_deployment_mode                      = "CLUSTER_MULTI_AZ"
    amazonmq_maintenance_window_start_day_of_week = "WEDNESDAY"
    amazonmq_maintenance_window_start_time_utc    = "06:00"
    amazonmq_host_instance_type                   = "mq.m5.xlarge"

    amazonmq_govuk_chat_retry_message_ttl = 300000
  }
}

module "variable-set-elasticache-production" {
  source = "./variable-set"

  name = "elasticache-production"

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
    caches = {
    }
  }
}

module "variable-set-elasticsearch-production" {
  source = "./variable-set"

  name = "elasticsearch-production"

  tfvars = {
    ebs = {
      volume_size      = 171
      volume_type      = "gp3"
      throughput       = 250
      provisioned_iops = 3000
    }

    engine_version         = "6.7"
    zone_awareness_enabled = true

    instance_count = 3
    instance_type  = "r5.4xlarge.elasticsearch"

    dedicated_master = {
      instance_count = 3
      instance_type  = "c5.xlarge.elasticsearch"
    }

    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"

    stackname = "blue"

    elasticsearch6_manual_snapshot_bucket_arns = [
      "arn:aws:s3:::govuk-production-elasticsearch6-manual-snapshots",
    ]

    encryption_at_rest = true
  }
}

module "variable-set-elasticsearch-green-production" {
  source = "./variable-set"

  name = "elasticsearch-green-production"

  tfvars = {
    ebs = {
      volume_size      = 314
      volume_type      = "gp3"
      throughput       = 250
      provisioned_iops = 3000
    }
    engine_version         = "6.8"
    zone_awareness_enabled = true

    instance_count = 3
    instance_type  = "r7i.4xlarge.elasticsearch"

    dedicated_master = {
      instance_count = 3
      instance_type  = "c7i.xlarge.elasticsearch"
    }

    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"

    stackname = "green"

    elasticsearch6_manual_snapshot_bucket_arns = [
      "arn:aws:s3:::govuk-production-green-elasticsearch6-manual-snapshots",
      "arn:aws:s3:::govuk-production-elasticsearch6-manual-snapshots"
    ]

    encryption_at_rest = true
  }
}

module "variable-set-gov-graph-production" {
  source = "./variable-set"

  name = "gov-graph-production"

  tfvars = {}
}
