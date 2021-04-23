locals {
  vpc_public_cidr_blocks = [
    for public_ip in data.terraform_remote_state.infra_networking.outputs.nat_gateway_elastic_ips_list :
    "${public_ip}/32"
  ]
}
