data "aws_regions" "enabled" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required", "opted-in"]
  }
}

resource "aws_accessanalyzer_analyzer" "analyzer" {
  for_each = local.is_ephemeral ? [] : toset(data.aws_regions.enabled.names)

  analyzer_name = "govuk-${each.key}"
  region        = each.key
}
