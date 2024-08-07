module "variable-set-production" {
  source = "./variable-set"

  name = "common-production"
  tfvars = {
    govuk_aws_state_bucket              = "govuk-terraform-steppingstone-production"
    cluster_infrastructure_state_bucket = "govuk-terraform-production"

    cluster_version               = "1.30"
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

    govuk_environment = "production"

    publishing_service_domain = "publishing.service.gov.uk"

    workers_instance_types         = ["m6i.8xlarge", "m6a.8xlarge"]
    frontend_memcached_node_type   = "cache.r6g.large"
    shared_redis_cluster_node_type = "cache.r6g.xlarge"

    ckan_s3_organogram_bucket = "datagovuk-production-ckan-organogram"
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
  }
}

# This has to be separate because the ':' get replaced with '='
#  by the var set module
resource "tfe_variable" "ecr-puller-arns" {
  variable_set_id = module.variable-set-ecr-production.variable_set_id
  key             = "puller_arns"
  category        = "terraform"
  value = jsonencode(
    [
      "arn:aws:iam::172025368201:root", # Production
      "arn:aws:iam::696911096973:root", # Staging
      "arn:aws:iam::210287912431:root", # Integration
      "arn:aws:iam::430354129336:root", # Test
    ]
  )
  hcl = true
}

module "variable-set-chat-production" {
  source = "./variable-set"

  name = "chat-production"

  tfvars = {
    chat_redis_cluster_apply_immediately          = false
    chat_redis_cluster_automatic_failover_enabled = true
    chat_redis_cluster_engine_version             = "7.1"
    chat_redis_cluster_multi_az_enabled           = true
    chat_redis_cluster_node_type                  = "cache.r6g.xlarge"
    chat_redis_cluster_num_cache_clusters         = "2"
    chat_redis_cluster_parameter_group_name       = "default.redis7"
    cloudfront_create                             = "1" 
    cloudfront_enable                             = True
    service_disabled                              = False
    origin_chat_domain                            = "chat.eks.production.govuk.digital"
    origin_chat_id                                = "Chat origin"
    cloudfront_chat_distribution_aliases          = ["chat.publishing.service.gov.uk"]
    chat_certificate_arn                          = "arn:aws:acm:us-east-1:172025368201:certificate/ea27535c-f48a-4755-b6ca-c048c880e02d"
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
        instance_class               = "db.t4g.small"
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
        instance_class               = "db.m6g.2xlarge"
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
        instance_class               = "db.t4g.medium"
        performance_insights_enabled = true
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
        instance_class               = "db.t4g.medium"
        performance_insights_enabled = true
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
        instance_class               = "db.t4g.medium"
        performance_insights_enabled = true
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
        instance_class               = "db.t4g.medium"
        performance_insights_enabled = true
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
        allocated_storage            = 1000
        instance_class               = "db.m6g.2xlarge"
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
        instance_class               = "db.t4g.medium"
        performance_insights_enabled = true
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
        allocated_storage            = 1000
        instance_class               = "db.m6g.2xlarge"
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
        allocated_storage            = 4500
        instance_class               = "db.m7g.2xlarge"
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
        instance_class               = "db.m6g.large"
        performance_insights_enabled = true
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
        instance_class               = "db.t4g.large"
        performance_insights_enabled = true
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
        instance_class               = "db.t4g.medium"
        performance_insights_enabled = true
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
        }
        engine_params_family         = "postgres13"
        name                         = "publishing-api"
        allocated_storage            = 1000
        instance_class               = "db.m6g.4xlarge"
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
        instance_class               = "db.t4g.small"
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
        instance_class               = "db.t4g.small"
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
        instance_class               = "db.t4g.medium"
        performance_insights_enabled = true
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
        instance_class               = "db.t4g.large"
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
        allocated_storage            = 300
        instance_class               = "db.m7g.xlarge"
        performance_insights_enabled = true
        freestoragespace_threshold   = 10737418240
        project                      = "GOV.UK - Publishing"
      }
    }
  }
}
