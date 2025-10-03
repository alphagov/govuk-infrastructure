resource "aws_security_group" "vpc_endpoints" {
  name        = "vpc-endpoints-${var.govuk_environment}"
  description = "Allow ingress from VPC on port 443"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id

  ingress {
    description = "Port 443 from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [for subnet in var.eks_private_subnets : subnet.cidr]
  }

  egress {
    description = "Port 443 to VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  count               = var.use_ecr_vpc_endpoints ? 1 : 0
  vpc_id              = data.tfe_outputs.vpc.nonsensitive_values.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids          = [for subnet in aws_subnet.eks_private : subnet.id]

  tags = {
    Name = "ecr-api-endpoint-${var.govuk_environment}"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  count               = var.use_ecr_vpc_endpoints ? 1 : 0
  vpc_id              = data.tfe_outputs.vpc.nonsensitive_values.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids          = [for subnet in aws_subnet.eks_private : subnet.id]

  tags = {
    Name = "ecr-dkr-endpoint-${var.govuk_environment}"
  }
}

resource "aws_vpc_endpoint" "s3" {
  count             = var.use_s3_vpc_endpoints ? 1 : 0
  vpc_id            = data.tfe_outputs.vpc.nonsensitive_values.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    [for rt in aws_route_table.eks_private : rt.id],
    data.tfe_outputs.vpc.nonsensitive_values.private_subnet_route_table_ids,
  )

  tags = {
    Name = "s3-endpoint-${var.govuk_environment}"
  }
}


resource "aws_vpc_endpoint" "secretsmanager" {
  count               = var.use_secretsmanager_endpoints ? 1 : 0
  vpc_id              = data.tfe_outputs.vpc.nonsensitive_values.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids          = [for subnet in aws_subnet.eks_private : subnet.id]

  tags = {
    Name = "secretsmanager-endpoint-${var.govuk_environment}"
  }
}
