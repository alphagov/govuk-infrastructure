resource "sentry_project" "govuk" {
  for_each = local.sentry_projects

  organization = "govuk"

  teams = concat(local.common_teams, each.value)
  name  = each.key
  slug  = "app-${each.key}"

  platform = "ruby"

  default_rules = false
  default_key   = true
}
