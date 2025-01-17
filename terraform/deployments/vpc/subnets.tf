locals {
  azs                        = { for name, subnet in var.legacy_public_subnets : subnet.az => name }
  nat_legacy_private_subnets = { for name, subnet in var.legacy_private_subnets : name => subnet if subnet["nat"] }
}

# Private subnets

resource "aws_subnet" "private_subnet" {
  for_each          = var.legacy_private_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags              = { Name = "govuk_private_${each.key}" }
}

# we want one NAT gateway per AZ
resource "aws_eip" "private_subnet_nat" {
  for_each = local.azs
  domain   = "vpc"
  tags     = { Name = "${each.key}-nat" }
}

resource "aws_nat_gateway" "private_subnet" {
  for_each      = local.azs
  allocation_id = aws_eip.private_subnet_nat[each.key].id
  subnet_id     = aws_subnet.public_subnet[each.value].id
}

resource "aws_route_table" "private_subnet" {
  for_each = var.legacy_private_subnets
  vpc_id   = aws_vpc.vpc.id
  tags     = { Name = "govuk_private_${each.key}" }
}

resource "aws_route_table_association" "private_subnet" {
  for_each       = var.legacy_private_subnets
  subnet_id      = aws_subnet.private_subnet[each.key].id
  route_table_id = aws_route_table.private_subnet[each.key].id
}

resource "aws_route" "private_subnet_nat" {
  for_each               = local.nat_legacy_private_subnets
  route_table_id         = aws_route_table.private_subnet[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.private_subnet[each.value.az].id
}

# Public subnets

resource "aws_subnet" "public_subnet" {
  for_each          = var.legacy_public_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags              = { Name = "govuk_public_${each.key}" }
}

resource "aws_route_table" "public_subnet" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "govuk_public" }
}

resource "aws_route_table_association" "public_subnet" {
  for_each       = var.legacy_public_subnets
  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public_subnet.id
}

resource "aws_route" "public_subnet_igw" {
  route_table_id         = aws_route_table.public_subnet.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public.id
}
