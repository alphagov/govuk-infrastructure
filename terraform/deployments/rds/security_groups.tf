resource "aws_security_group" "rds" {
  for_each = var.databases

  name        = "blue_${each.value.name}_rds_access"
  vpc_id      = data.terraform_remote_state.infra_vpc.outputs.vpc_id
  description = "Access to ${each.value.name} RDS"
  tags        = { Name = "blue_${each.value.name}_rds_access" }
}
