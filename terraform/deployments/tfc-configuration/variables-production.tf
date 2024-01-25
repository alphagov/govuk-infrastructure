module "variable-set-production" {
  source = "./variable-set"

  name = "common-production"
  tfvars = {
    govuk_aws_state_bucket              = "govuk-terraform-steppingstone-production"
    cluster_infrastructure_state_bucket = "govuk-terraform-production"

    cluster_version               = 1.28
    cluster_log_retention_in_days = 7

    eks_control_plane_subnets = {
      a = { az = "eu-west-1a", cidr = "10.13.19.0/28" }
      b = { az = "eu-west-1b", cidr = "10.13.19.16/28" }
      c = { az = "eu-west-1c", cidr = "10.13.19.32/28" }
    }

    eks_licensify_gateways = {
      a = { az = "eu-west-1a", cidr = "10.13.20.0/24", eip = "eipalloc-054c895a7e019c1f3" }
      b = { az = "eu-west-1b", cidr = "10.13.21.0/24", eip = "eipalloc-0d5465010fda7ba1d" }
      c = { az = "eu-west-1c", cidr = "10.13.22.0/24", eip = "eipalloc-083611260a167ea49" }
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
    puller_arns = [
      "arn:aws:iam::172025368201:root", # Production
      "arn:aws:iam::696911096973:root", # Staging
      "arn:aws:iam::210287912431:root", # Integration
      "arn:aws:iam::430354129336:root", # Test
    ]

    emails = [
      # TODO: manage this via a mailing list so as not to introduce toil.
      "nadeem.sabri@digital.cabinet-office.gov.uk",
      "chris.banks@digital.cabinet-office.gov.uk",
    ]
  }
}
