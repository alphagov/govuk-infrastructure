data "aws_region" "current" {}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "govuk-${var.govuk_environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "govuk-${var.govuk_environment}"
  }
}

removed {
  from = aws_route_table.public
  lifecycle {
    destroy = false
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
}
