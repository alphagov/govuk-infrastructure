# Network config primarily for using with ECS RunTask, which requires both
# a task definition and a network config (ideally the same network config
# used by the ECS Service, so the task started by RunTask can access the same
# resources).

# TODO: Move the network config module into this file.
module "network_config" {
  source          = "../task-network-config"
  subnets         = var.subnets
  security_groups = local.service_security_groups
}

output "network_config" {
  value = module.network_config.network_config
}
