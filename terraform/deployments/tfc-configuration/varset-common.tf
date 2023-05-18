resource "tfe_variable_set" "common" {
  name        = "Common_infrastructure"
  description = "Some description."
  global      = false
}

resource "tfe_variable" "dex_github_orgs_teams" {
  key             = "dex_github_orgs_teams"
  value           = "[{ name = \"alphagov\", teams = [\"gov-uk\", \"gov-uk-production-deploy\"] }]"
  category        = "terraform"
  hcl             = true
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common.id
}

# resource "tfe_variable" "blank" {
#   key = "name"
#   value = "val"
#   category        = "terraform"
#   description     = "a useful description"
#   variable_set_id = tfe_variable_set.common.id
# }
