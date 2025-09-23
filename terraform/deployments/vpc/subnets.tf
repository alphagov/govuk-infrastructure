locals {
  azs = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c"
  ]
}

# Private subnets

# Preserve EIPs from Legacy Subnets/NATs
resource "aws_eip" "private_subnet_nat" {
  for_each = toset(local.azs)
  domain   = "vpc"
  tags = {
    Name    = "${each.key}-nat"
    Purpose = "EIP Retained for Legacy ELMS Endpoints"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_subnet" "private_subnet" {
  for_each          = var.legacy_private_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags              = { Name = "govuk_private_${each.key}" }
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

resource "aws_route_table" "public_subnet" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "govuk_public" }
}

resource "aws_route" "public_subnet_igw" {
  route_table_id         = aws_route_table.public_subnet.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public.id
}
