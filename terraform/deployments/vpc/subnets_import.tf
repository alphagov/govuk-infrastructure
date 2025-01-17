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

data "aws_subnet" "public_subnet_import" {
  for_each = var.legacy_public_subnets
  filter {
    name   = "tag:Name"
    values = ["govuk_public_${each.key}"]
  }
}

data "aws_eip" "nat_eip_import" {
  for_each = local.azs
  filter {
    name   = "tag:Name"
    values = ["govuk-legacy-nat-${each.value}"]
  }
}

import {
  for_each = local.azs
  to       = aws_eip.private_subnet_nat[each.key]
  id       = data.aws_eip.nat_eip_import[each.key].id
}

data "aws_nat_gateway" "private_subnet_import" {
  for_each = local.azs
  filter {
    name   = "tag:Name"
    values = ["govuk-legacy-${each.value}"]
  }
}

import {
  for_each = local.azs
  to       = aws_nat_gateway.private_subnet[each.key]
  id       = data.aws_nat_gateway.private_subnet_import[each.key].id
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

import {
  for_each = var.legacy_public_subnets
  to       = aws_subnet.public_subnet[each.key]
  id       = data.aws_subnet.public_subnet_import[each.key].id
}

data "aws_route_table" "public_subnet_import" {
  filter {
    name   = "tag:Name"
    values = ["govuk-${var.govuk_environment}"]
  }
}

import {
  to = aws_route_table.public_subnet
  id = data.aws_route_table.public_subnet_import.id
}

import {
  for_each = var.legacy_public_subnets
  to       = aws_route_table_association.public_subnet[each.key]
  id       = "${data.aws_subnet.public_subnet_import[each.key].id}/${data.aws_route_table.public_subnet_import.id}"
}

import {
  to = aws_route.public_subnet_igw
  id = "${data.aws_route_table.public_subnet_import.id}_0.0.0.0/0"
}
