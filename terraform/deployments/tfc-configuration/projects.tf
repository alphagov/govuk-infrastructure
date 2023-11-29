resource "tfe_project" "tfe_projects" {
  for_each     = toset(var.project_names)
  name         = each.value
  organization = var.organization
}

