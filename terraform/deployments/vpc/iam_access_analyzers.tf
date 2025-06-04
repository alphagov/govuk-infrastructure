resource "aws_accessanalyzer_analyzer" "ap-northeast-1" {
  analyzer_name = "govuk-ap-northeast-1"
  provider      = aws.ap-northeast-1
  count         = local.is_ephemeral ? 0 : 1
}

resource "aws_accessanalyzer_analyzer" "ap-northeast-2" {
  analyzer_name = "govuk-ap-northeast-2"
  provider      = aws.ap-northeast-2
  count         = local.is_ephemeral ? 0 : 1
}

resource "aws_accessanalyzer_analyzer" "ap-northeast-3" {
  analyzer_name = "govuk-ap-northeast-3"
  provider      = aws.ap-northeast-3
  count         = local.is_ephemeral ? 0 : 1
}

resource "aws_accessanalyzer_analyzer" "ap-south-1" {
  analyzer_name = "govuk-ap-south-1"
  provider      = aws.ap-south-1
  count         = local.is_ephemeral ? 0 : 1
}

resource "aws_accessanalyzer_analyzer" "ap-southeast-1" {
  analyzer_name = "govuk-ap-southeast-1"
  provider      = aws.ap-southeast-1
  count         = local.is_ephemeral ? 0 : 1
}

resource "aws_accessanalyzer_analyzer" "ap-southeast-2" {
  analyzer_name = "govuk-ap-southeast-2"
  provider      = aws.ap-southeast-2
  count         = local.is_ephemeral ? 0 : 1
}

resource "aws_accessanalyzer_analyzer" "ca-central-1" {
  analyzer_name = "govuk-ca-central-1"
  provider      = aws.ca-central-1
  count         = local.is_ephemeral ? 0 : 1
}

resource "aws_accessanalyzer_analyzer" "eu-central-1" {
  analyzer_name = "govuk-eu-central-1"
  provider      = aws.eu-central-1
  count         = local.is_ephemeral ? 0 : 1
}

resource "aws_accessanalyzer_analyzer" "eu-north-1" {
  analyzer_name = "govuk-eu-north-1"
  provider      = aws.eu-north-1
  count         = local.is_ephemeral ? 0 : 1
}

resource "aws_accessanalyzer_analyzer" "eu-west-1" {
  analyzer_name = "govuk-eu-west-1"
  provider      = aws.eu-west-1
  count         = local.is_ephemeral ? 0 : 1
}

resource "aws_accessanalyzer_analyzer" "eu-west-2" {
  analyzer_name = "govuk-eu-west-2"
  provider      = aws.eu-west-2
  count         = local.is_ephemeral ? 0 : 1
}

resource "aws_accessanalyzer_analyzer" "eu-west-3" {
  analyzer_name = "govuk-eu-west-3"
  provider      = aws.eu-west-3
  count         = local.is_ephemeral ? 0 : 1
}

resource "aws_accessanalyzer_analyzer" "sa-east-1" {
  analyzer_name = "govuk-sa-east-1"
  provider      = aws.sa-east-1
  count         = local.is_ephemeral ? 0 : 1
}

resource "aws_accessanalyzer_analyzer" "us-east-1" {
  analyzer_name = "govuk-us-east-1"
  provider      = aws.us-east-1
  count         = local.is_ephemeral ? 0 : 1
}

resource "aws_accessanalyzer_analyzer" "us-east-2" {
  analyzer_name = "govuk-us-east-2"
  provider      = aws.us-east-2
  count         = local.is_ephemeral ? 0 : 1
}

resource "aws_accessanalyzer_analyzer" "us-west-1" {
  analyzer_name = "govuk-us-west-1"
  provider      = aws.us-west-1
  count         = local.is_ephemeral ? 0 : 1
}

resource "aws_accessanalyzer_analyzer" "us-west-2" {
  analyzer_name = "govuk-us-west-2"
  provider      = aws.us-west-2
  count         = local.is_ephemeral ? 0 : 1
}

