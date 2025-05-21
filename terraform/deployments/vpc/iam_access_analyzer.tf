resource "aws_accessanalyzer_analyzer" "govuk" {
  count         = local.is_ephemeral ? 0 : 1
  analyzer_name = "govuk"
}
