resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.environment_name}-vpc-endpoints"
  description = "Allow ingress from VPC on port 443"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Port 443 from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [for subnet, cidr in local.subnets_config.private : cidr]
  }

  egress {
    description = "Port 443 to VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "bedrock_runtime" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.bedrock-runtime"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]

  tags = {
    Name = "${var.environment_name}-bedrock-runtime-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]

  tags = {
    Name = "${var.environment_name}-ecr-api-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]

  tags = {
    Name = "${var.environment_name}-ecr-dkr-endpoint"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [for rt in aws_route_table.private : rt.id]

  tags = {
    Name = "${var.environment_name}-s3-endpoint"
  }
}


resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]

  tags = {
    Name = "${var.environment_name}-secretsmanager-endpoint"
  }
}
