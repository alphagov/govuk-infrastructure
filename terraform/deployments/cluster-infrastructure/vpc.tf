# vpc.tf manages the subnets for the EKS cluster and their associated
# paraphernalia such as NAT gateways and route tables. The VPC itself is
# defined in https://github.com/alphagov/govuk-aws/ while we transition to
# Kubernetes.
#
# https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html

# TODO: Once the EC2 environment is gone, move the aws_vpc from
# alphagov/govuk-aws to here.

# TODO: Consider factoring out the (subnet, route_table,
# route_table_association, route) resources into a local module (or maybe two,
# for public/private), perhaps after we've imported the VPC resource from
# govuk-aws. Also consider using terraform-aws-modules/terraform-aws-vpc to
# replace the whole lot. (That module makes some dubious use of count() but
# it's ok because we're very unlikely to add or remove availability zones.)

locals {
  route_create_timeout = "5m" # Same workaround as terraform-aws-vpc module.
}


# Control plane subnets and associated resources. The control plane subnets are
# small, private subnets where EKS creates the ENIs for private access to
# the master node, which runs in an Amazon-owned VPC.

resource "aws_subnet" "eks_control_plane" {
  for_each          = var.eks_control_plane_subnets
  vpc_id            = data.terraform_remote_state.infra_vpc.outputs.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags              = { Name = "${var.cluster_name}-eks-control-plane-${each.key}" }
}

resource "aws_route_table" "eks_control_plane" {
  for_each = var.eks_control_plane_subnets
  vpc_id   = data.terraform_remote_state.infra_vpc.outputs.vpc_id
  tags     = { Name = "${var.cluster_name}-eks-control-plane-${each.key}" }
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
  nat_gateway_id         = length(var.eks_licensify_gateways) == 0 ? aws_nat_gateway.eks[each.key].id : aws_nat_gateway.eks_licensify[each.key].id
  timeouts {
    create = local.route_create_timeout
  }
}


# Public subnets and associated resources. The public subnets are used by
# controllers in the cluster (such as aws-load-balancer-controller) for
# creating Internet-facing load balancers.

resource "aws_subnet" "eks_public" {
  for_each          = var.eks_public_subnets
  vpc_id            = data.terraform_remote_state.infra_vpc.outputs.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = "${var.cluster_name}-eks-public-${each.key}"
    # https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/elb"                    = "1"
  }
  map_public_ip_on_launch = true
}

resource "aws_route_table" "eks_public" {
  vpc_id = data.terraform_remote_state.infra_vpc.outputs.vpc_id
  tags   = { Name = "${var.cluster_name}-eks-public" }
}

resource "aws_route_table_association" "eks_public" {
  for_each       = var.eks_public_subnets
  subnet_id      = aws_subnet.eks_public[each.key].id
  route_table_id = aws_route_table.eks_public.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.eks_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.terraform_remote_state.infra_vpc.outputs.internet_gateway_id
  timeouts { create = local.route_create_timeout }
}

resource "aws_eip" "eks_nat" {
  for_each = var.eks_public_subnets
  vpc      = true
  tags     = { Name = "${var.cluster_name}-eks-nat-${each.key}" }
  # TODO: depends_on = [aws_internet_gateway.gw] once we've imported the IGW from govuk-aws.
}

resource "aws_nat_gateway" "eks" {
  for_each      = var.eks_public_subnets
  allocation_id = aws_eip.eks_nat[each.key].id
  subnet_id     = aws_subnet.eks_public[each.key].id
  tags          = { Name = "${var.cluster_name}-eks-${each.key}" }
  # TODO: depends_on = [aws_internet_gateway.gw] once we've imported the IGW from govuk-aws.
}

data "aws_eip" "eks_licensify" {
  for_each = var.eks_licensify_gateways
  id       = each.value.eip
}

# Should be skipped on Integration
resource "aws_nat_gateway" "eks_licensify" {
  for_each      = var.eks_licensify_gateways
  allocation_id = each.value.eip
  subnet_id     = aws_subnet.eks_public[each.key].id
  tags          = { Name = "${var.cluster_name}-eks-licensify-${each.key}" }
  # TODO: depends_on = [aws_internet_gateway.gw] once we've imported the IGW from govuk-aws.
}


# Private subnets and associated resources. The private subnets contain the
# worker nodes and the pods.

resource "aws_subnet" "eks_private" {
  for_each          = var.eks_private_subnets
  vpc_id            = data.terraform_remote_state.infra_vpc.outputs.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = "${var.cluster_name}-eks-private-${each.key}"
    # https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

resource "aws_route_table" "eks_private" {
  for_each = var.eks_private_subnets
  vpc_id   = data.terraform_remote_state.infra_vpc.outputs.vpc_id
  tags     = { Name = "${var.cluster_name}-eks-private-${each.key}" }
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
  nat_gateway_id         = length(var.eks_licensify_gateways) == 0 ? aws_nat_gateway.eks[each.key].id : aws_nat_gateway.eks_licensify[each.key].id
  timeouts { create = local.route_create_timeout }
}
