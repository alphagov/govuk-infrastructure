module "variable-set-staging" {
  source = "./variable-set"

  name = "common-staging"
  tfvars = {
    govuk_aws_state_bucket              = "govuk-terraform-steppingstone-staging"
    cluster_infrastructure_state_bucket = "govuk-terraform-staging"

    cluster_version               = "1.30"
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

    govuk_environment = "staging"

    publishing_service_domain = "staging.publishing.service.gov.uk"

    frontend_memcached_node_type   = "cache.t4g.medium"
    shared_redis_cluster_node_type = "cache.r6g.large"

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
    chat_redis_cluster_engine_version             = "7.1"
    chat_redis_cluster_multi_az_enabled           = false
    chat_redis_cluster_node_type                  = "cache.r6g.xlarge"
    chat_redis_cluster_num_cache_clusters         = "1"
    chat_redis_cluster_parameter_group_name       = "default.redis7"
    cloudfront_create                             = "1" 
    cloudfront_enable                             = True
    service_disabled                              = False
    origin_chat_domain                            = "chat.staging.publishing.service.gov.uk"
    origin_chat_id                                =
    origin_service_disabled_domain                =
    origin_service_disabled_id                    =
    cloudfront_chat_distribution_aliases          =
    chat_certificate_arn                          =
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
        engine_params_family         = "postgres13"
        name                         = "account-api"
        allocated_storage            = 100
        instance_class               = "db.t4g.medium"
        performance_insights_enabled = true
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Web"
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
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Publishing"
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
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - AI"
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
        engine_params_family         = "postgres13"
        name                         = "ckan"
        allocated_storage            = 1000
        instance_class               = "db.m6g.large"
        performance_insights_enabled = true
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - DGU"
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
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Publishing"
      }

      contacts_admin = {
        engine         = "mysql"
        engine_version = "8.0"
        engine_params = {
          max_allowed_packet = { value = 1073741824 }
        }
        engine_params_family         = "mysql8.0"
        name                         = "contacts-admin"
        allocated_storage            = 100
        instance_class               = "db.t4g.small"
        performance_insights_enabled = false
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Publishing"
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
        engine_params_family         = "postgres13"
        name                         = "content-data-admin"
        allocated_storage            = 100
        instance_class               = "db.t4g.micro"
        performance_insights_enabled = false
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Publishing"
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
        }
        engine_params_family         = "postgres13"
        name                         = "blue-content-data-api-postgresql-primary"
        allocated_storage            = 1024
        instance_class               = "db.m6g.large"
        performance_insights_enabled = false
        freestoragespace_threshold   = 536870912000
        project                      = "GOV.UK - Publishing"
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
        engine_params_family         = "postgres13"
        name                         = "content-publisher"
        allocated_storage            = 100
        instance_class               = "db.t4g.small"
        performance_insights_enabled = false
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Publishing"
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
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Publishing"
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
        engine_params_family         = "postgres13"
        name                         = "content-tagger"
        allocated_storage            = 100
        instance_class               = "db.t4g.small"
        performance_insights_enabled = false
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Publishing"
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
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Publishing"
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
        engine_params_family         = "postgres13"
        name                         = "email-alert-api"
        allocated_storage            = 1000
        instance_class               = "db.m6g.xlarge"
        performance_insights_enabled = true
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Web"
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
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Web"
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
        engine_params_family         = "postgres13"
        name                         = "link-checker-api"
        allocated_storage            = 100
        instance_class               = "db.t4g.medium"
        performance_insights_enabled = false
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Publishing"
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
        engine_params_family         = "postgres13"
        name                         = "local-links-manager"
        allocated_storage            = 100
        instance_class               = "db.t4g.small"
        performance_insights_enabled = false
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Web"
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
        engine_params_family         = "postgres13"
        name                         = "locations-api"
        allocated_storage            = 1000
        instance_class               = "db.m6g.large"
        performance_insights_enabled = true
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Web"
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
        engine_params_family         = "postgres13"
        name                         = "publishing-api"
        allocated_storage            = 1000
        instance_class               = "db.m6g.large"
        performance_insights_enabled = true
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Publishing"
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
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Infrastructure"
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
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Search"
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
        engine_params_family         = "postgres13"
        name                         = "service-manual-publisher"
        allocated_storage            = 100
        instance_class               = "db.t4g.micro"
        performance_insights_enabled = false
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Publishing"
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
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Publishing"
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
        engine_params_family         = "postgres13"
        name                         = "support-api"
        allocated_storage            = 200
        instance_class               = "db.t4g.medium"
        performance_insights_enabled = true
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Publishing"
      }

      transition = {
        engine         = "postgres"
        engine_version = "13"
        engine_params = {
          log_min_duration_statement = { value = 10000 }
          log_statement              = { value = "all" }
          deadlock_timeout           = { value = 2500 }
          log_lock_waits             = { value = 1 }
        }
        engine_params_family         = "postgres13"
        name                         = "transition"
        allocated_storage            = 120
        instance_class               = "db.m6g.large" # TODO: downsize this after migration if required
        performance_insights_enabled = true
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Publishing"
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
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Publishing"
      }
    }
  }
}
