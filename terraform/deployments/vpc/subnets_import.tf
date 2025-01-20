data "aws_subnet" "private_subnet_import" {
  for_each = var.legacy_private_subnets
  filter {
    name   = "tag:Name"
    values = ["govuk_private_${each.key}"]
  }
}

import {
  for_each = var.legacy_private_subnets
  to       = aws_subnet.private_subnet[each.key]
  id       = data.aws_subnet.private_subnet_import[each.key].id
}

data "aws_route_table" "private_subnet_import" {
  for_each  = var.legacy_private_subnets
  subnet_id = data.aws_subnet.private_subnet_import[each.key].id
}

import {
  for_each = var.legacy_private_subnets
  to       = aws_route_table.private_subnet[each.key]
  id       = data.aws_route_table.private_subnet_import[each.key].id
}

import {
  for_each = var.legacy_private_subnets
  to       = aws_route_table_association.private_subnet[each.key]
  id       = "${data.aws_subnet.private_subnet_import[each.key].id}/${data.aws_route_table.private_subnet_import[each.key].id}"
}

import {
  for_each = local.nat_legacy_private_subnets
  to       = aws_route.private_subnet_nat[each.key]
  id       = "${data.aws_route_table.private_subnet_import[each.key].id}_0.0.0.0/0"
}
