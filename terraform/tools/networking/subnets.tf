locals {
  route_create_timeout = "5m"

  public_subnet_prefix_size        = 8
  private_subnet_prefix_size       = 8
  control_plane_subnet_prefix_size = 12

  # subdivide network range into /24 and and /28 blocks
  all_subnet_ranges = cidrsubnets(
    var.vpc_cidr,
    # public; 1 per az
    local.public_subnet_prefix_size,
    local.public_subnet_prefix_size,
    local.public_subnet_prefix_size,

    # private; 1 per az
    local.private_subnet_prefix_size,
    local.private_subnet_prefix_size,
    local.private_subnet_prefix_size,

    # control plane; 1 per az
    local.control_plane_subnet_prefix_size,
    local.control_plane_subnet_prefix_size,
    local.control_plane_subnet_prefix_size,
  )

  public_subnets        = [local.all_subnet_ranges[0], local.all_subnet_ranges[1], local.all_subnet_ranges[2]]
  private_subnets       = [local.all_subnet_ranges[3], local.all_subnet_ranges[4], local.all_subnet_ranges[5]]
  control_plane_subnets = [local.all_subnet_ranges[6], local.all_subnet_ranges[7], local.all_subnet_ranges[8]]

  subnets_config = {
    public = {
      "eu-west-1a" = local.public_subnets[0],
      "eu-west-1b" = local.public_subnets[1],
      "eu-west-1c" = local.public_subnets[2],
    },
    private = {
      "eu-west-1a" = local.private_subnets[0],
      "eu-west-1b" = local.private_subnets[1],
      "eu-west-1c" = local.private_subnets[2],
    },
    control_plane = {
      "eu-west-1a" = local.control_plane_subnets[0],
      "eu-west-1b" = local.control_plane_subnets[1],
      "eu-west-1c" = local.control_plane_subnets[2],
    }
  }
}

resource "aws_nat_gateway" "regional_nat" {
  vpc_id            = aws_vpc.vpc.id
  availability_mode = "regional"
  tags              = { Name = "${var.environment_name}-nat-gateway" }
}

# Control plane subnets and associated resources. The control plane subnets are
# small, private subnets where EKS creates the ENIs for private access to
# the master node, which runs in an Amazon-owned VPC.

resource "aws_subnet" "eks_control_plane" {
  for_each          = local.subnets_config.control_plane
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value
  availability_zone = each.key
  tags              = { Name = "${var.environment_name}-eks-control-plane-${each.key}" }
}

resource "aws_route_table" "eks_control_plane" {
  for_each = local.subnets_config.control_plane
  vpc_id   = aws_vpc.vpc.id
  tags     = { Name = "${var.environment_name}-eks-control-plane-${each.key}" }
}


resource "aws_route_table_association" "eks_control_plane" {
  for_each       = local.subnets_config.control_plane
  subnet_id      = aws_subnet.eks_control_plane[each.key].id
  route_table_id = aws_route_table.eks_control_plane[each.key].id
}

resource "aws_route" "eks_control_plane_nat" {
  for_each               = local.subnets_config.control_plane
  route_table_id         = aws_route_table.eks_control_plane[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.regional_nat.id
  timeouts {
    create = local.route_create_timeout
  }
}


# Public subnets and associated resources. The public subnets are used by
# controllers in the cluster (such as aws-load-balancer-controller) for
# creating Internet-facing load balancers.

resource "aws_subnet" "public" {
  for_each          = local.subnets_config.public
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value
  availability_zone = each.key
  tags = {
    Name = "${var.environment_name}-public-${each.key}"
    # https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
    "kubernetes.io/cluster/${var.environment_name}" = "owned"
    "kubernetes.io/role/elb"                        = "1"
  }
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "${var.environment_name}-public" }
}

resource "aws_route_table_association" "public" {
  for_each       = local.subnets_config.public
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public.id
  timeouts { create = local.route_create_timeout }
}

# Private subnets and associated resources. The private subnets contain the
# worker nodes and the pods.

resource "aws_subnet" "private" {
  for_each          = local.subnets_config.private
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value
  availability_zone = each.key
  tags = {
    Name = "${var.environment_name}-private-${each.key}"
    # https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
    "kubernetes.io/cluster/${var.environment_name}" = "owned"
    "kubernetes.io/role/internal-elb"               = "1"
  }
}

resource "aws_route_table" "private" {
  for_each = local.subnets_config.private
  vpc_id   = aws_vpc.vpc.id
  tags     = { Name = "${var.environment_name}-private-${each.key}" }
}

resource "aws_route_table_association" "private" {
  for_each       = local.subnets_config.private
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route" "private_nat" {
  for_each               = local.subnets_config.private
  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.regional_nat.id
  timeouts { create = local.route_create_timeout }
}
