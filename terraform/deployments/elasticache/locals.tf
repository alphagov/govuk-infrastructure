locals {
  elasticache_subnets = [
    for name, subnet in data.tfe_outputs.vpc.nonsensitive_values.private_subnet_ids : subnet
    if length(regexall("elasticache_", name)) > 0
  ]
}
