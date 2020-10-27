locals {
  govuk_app_domain_external        = "www.test.publishing.service.gov.uk"
  govuk_app_domain_internal        = "test.govuk-internal.digital"
  govuk_website_root               = "www.test.publishing.service.gov.uk"
  mesh_name                        = "govuk"
  mongodb_host                     = "mongo-1.test.govuk-internal.digital,mongo-2.test.govuk-internal.digital,mongo-3.test.govuk-internal.digital"
  service_discovery_namespace_name = "mesh.govuk-internal.digital"
  sentry_environment               = "test"
  statsd_host                      = "statsd.test.govuk-internal.digital"
  redis_host                       = "pink-backend-redis.0f3erf.ng.0001.euw1.cache.amazonaws.com"
  redis_port                       = 6379
  asset_host                       = "www.gov.uk" # TODO: this looks wrong
}

data "aws_iam_role" "execution" {
  name = "fargate_execution_role"
}

data "aws_iam_role" "task" {
  name = "fargate_task_role"
}
