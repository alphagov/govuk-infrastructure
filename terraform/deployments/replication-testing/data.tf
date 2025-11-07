data "aws_security_group" "content_data_api_source" {
  id = "sg-0afc1877382f550a9"
}

data "aws_security_group" "content_data_api_target" {
  id = "sg-0536dd612f649921a"
}

data "aws_security_group" "whitehall_source" {
  id = "sg-039dbce87248e8d2b"
}

data "aws_security_group" "whitehall_target" {
  id = "sg-0a88c4e78e38f11bb"
}

data "aws_vpc" "govuk" {
  id = "vpc-53cd2235"
}
