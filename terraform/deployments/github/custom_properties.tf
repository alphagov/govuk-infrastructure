data "github_organization_custom_properties" "team_identifier" {
  property_name = "team_identifier"
  value_type    = "single_select"
}

data "http" "repos_yml" {
  url = "https://docs.publishing.service.gov.uk/repos.json"

  request_headers = {
    Accept = "application/json"
  }
}

resource "github_repository_custom_property" "team_identifier" {
  for_each = local.repos_yml_teams

  repository     = each.key
  property_name  = data.github_organization_custom_properties.team_identifier.property_name
  property_type  = data.github_organization_custom_properties.team_identifier.value_type
  property_value = [contains(data.github_organization_custom_properties.team_identifier.allowed_values, each.value) ? each.value : "other"]
}

resource "github_repository_custom_property" "team_other" {
  for_each = {
    for k, v in local.repos_yml_teams : k => v
    if !contains(data.github_organization_custom_properties.team_identifier.allowed_values, v)
  }

  repository     = each.key
  property_name  = "team_other"
  property_type  = "string"
  property_value = [each.value]
}
