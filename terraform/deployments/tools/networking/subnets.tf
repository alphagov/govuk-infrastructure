locals {
  azs = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c"
  ]

  route_create_timeout = "5m" # Same workaround as terraform-aws-vpc module.
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

# Control plane subnets and associated resources. The control plane subnets are
# small, private subnets where EKS creates the ENIs for private access to
# the master node, which runs in an Amazon-owned VPC.

resource "aws_subnet" "eks_control_plane" {
  for_each          = var.eks_control_plane_subnets
  vpc_id            = data.tfe_outputs.vpc.nonsensitive_values.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags              = { Name = "eks-control-plane-${each.key}" }
}

resource "aws_route_table" "eks_control_plane" {
  for_each = var.eks_control_plane_subnets
  vpc_id   = data.tfe_outputs.vpc.nonsensitive_values.id
  tags     = { Name = "eks-control-plane-${each.key}" }
}


resource "aws_route_table_association" "eks_control_plane" {
  for_each       = var.eks_control_plane_subnets
  subnet_id      = aws_subnet.eks_control_plane[each.key].id
  route_table_id = aws_route_table.eks_control_plane[each.key].id
}

resource "aws_route" "eks_control_plane_nat" {
  for_each               = var.eks_control_plane_subnets
  route_table_id         = aws_route_table.eks_control_plane[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.eks[each.key].id
  timeouts {
    create = local.route_create_timeout
  }
}


# Public subnets and associated resources. The public subnets are used by
# controllers in the cluster (such as aws-load-balancer-controller) for
# creating Internet-facing load balancers.

resource "aws_subnet" "eks_public" {
  for_each          = var.eks_public_subnets
  vpc_id            = data.tfe_outputs.vpc.nonsensitive_values.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = "eks-public-${each.key}"
    # https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/elb"                    = "1"
  }
  map_public_ip_on_launch = true
}

resource "aws_route_table" "eks_public" {
  vpc_id = data.tfe_outputs.vpc.nonsensitive_values.id
  tags   = { Name = "eks-public" }
}

resource "aws_route_table_association" "eks_public" {
  for_each       = var.eks_public_subnets
  subnet_id      = aws_subnet.eks_public[each.key].id
  route_table_id = aws_route_table.eks_public.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.eks_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.tfe_outputs.vpc.nonsensitive_values.internet_gateway_id
  timeouts { create = local.route_create_timeout }
}

resource "aws_eip" "eks_nat" {
  for_each = var.eks_public_subnets
  domain   = "vpc"
  tags     = { Name = "eks-nat-${each.key}" }
}

resource "aws_nat_gateway" "eks" {
  for_each      = var.eks_public_subnets
  allocation_id = aws_eip.eks_nat[each.key].id
  subnet_id     = aws_subnet.eks_public[each.key].id
  tags          = { Name = "eks-${each.key}" }
}

# Private subnets and associated resources. The private subnets contain the
# worker nodes and the pods.

resource "aws_subnet" "eks_private" {
  for_each          = var.eks_private_subnets
  vpc_id            = data.tfe_outputs.vpc.nonsensitive_values.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = "eks-private-${each.key}"
    # https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

resource "aws_route_table" "eks_private" {
  for_each = var.eks_private_subnets
  vpc_id   = data.tfe_outputs.vpc.nonsensitive_values.id
  tags     = { Name = "eks-private-${each.key}" }
}

resource "aws_route_table_association" "eks_private" {
  for_each       = var.eks_private_subnets
  subnet_id      = aws_subnet.eks_private[each.key].id
  route_table_id = aws_route_table.eks_private[each.key].id
}

resource "aws_route" "eks_private_nat" {
  for_each               = var.eks_private_subnets
  route_table_id         = aws_route_table.eks_private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.eks[each.key].id
  timeouts { create = local.route_create_timeout }
}

