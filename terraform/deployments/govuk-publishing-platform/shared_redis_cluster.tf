# TODO - inline this module

module "shared_redis_cluster" {
  source              = "../../modules/redis"
  vpc_id              = local.vpc_id
  internal_app_domain = var.internal_app_domain
  subnet_ids          = local.redis_subnets
}

