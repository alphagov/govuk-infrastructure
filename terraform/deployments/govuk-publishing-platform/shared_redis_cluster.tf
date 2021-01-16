# TODO - inline this module

module "shared_redis_cluster" {
  source               = "../../modules/redis"
  vpc_id               = local.vpc_id
  internal_domain_name = var.internal_domain_name
  subnet_ids           = local.redis_subnets
}

