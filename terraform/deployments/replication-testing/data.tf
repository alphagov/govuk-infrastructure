data "aws_security_group" "content_data_api_source" {
  id = "sg-0afc1877382f550a9"
}

data "aws_security_group" "content_data_api_target" {
  id = "sg-0536dd612f649921a"
}

data "aws_vpc" "govuk" {
  id = "vpc-53cd2235"
}
