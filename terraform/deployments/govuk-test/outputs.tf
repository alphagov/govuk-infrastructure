output "private_subnets" {
  value = data.terraform_remote_state.infra_networking.outputs.private_subnet_ids
}

output "publisher_security_groups" {
  value = module.govuk.publisher_security_groups
}
