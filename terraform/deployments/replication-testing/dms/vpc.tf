resource "aws_subnet" "dms_a" {
  vpc_id                  = data.aws_vpc.govuk.id
  cidr_block              = "10.1.100.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "jfharden-dms-a"
  }
}

resource "aws_subnet" "dms_b" {
  vpc_id                  = data.aws_vpc.govuk.id
  cidr_block              = "10.1.101.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "jfharden-dms-b"
  }
}

resource "aws_subnet" "dms_c" {
  vpc_id                  = data.aws_vpc.govuk.id
  cidr_block              = "10.1.102.0/24"
  availability_zone       = "eu-west-1c"
  map_public_ip_on_launch = false

  tags = {
    Name = "jfharden-dms-c"
  }
}
