module "variable-set-common" {
  source = "./variable-set"

  name     = "common"
  priority = false
  tfvars = {
    dex_github_orgs_teams = [{
      name  = "alphagov"
      teams = ["gov-uk", "gov-uk-production-deploy"]
    }]
  }
}


module "sensitive-variables" {
  source  = "app.terraform.io/govuk/infrastructure-sensitive/govuk//modules/variables"
  version = "0.0.9"
}
