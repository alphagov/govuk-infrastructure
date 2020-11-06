output "private_subnets" {
  value = var.private_subnets
}

output "publisher_security_groups" {
  value = module.govuk.publisher_security_groups
}
