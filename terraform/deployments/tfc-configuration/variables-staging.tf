module "variable-set-staging" {
  source = "./variable-set"

  name = "common-staging"
  tfvars = {
    govuk_aws_state_bucket              = "govuk-terraform-steppingstone-staging"
    cluster_infrastructure_state_bucket = "govuk-terraform-staging"

    cluster_version               = 1.28
    cluster_log_retention_in_days = 7

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
