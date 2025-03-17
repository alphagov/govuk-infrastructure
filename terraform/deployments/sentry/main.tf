resource "sentry_project" "govuk" {
  for_each = toset(local.sentry_projects)

  organization = "govuk"

  teams = local.common_teams
  name  = each.key
  slug  = "app-${each.key}"

  platform = "ruby"

  default_rules = false
  default_key   = true
}
