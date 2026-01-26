module "variable-set-common" {
  source = "./variable-set"

  name     = "common"
  priority = false
  tfvars = {
    dex_github_orgs_teams = [{
      name = "alphagov"
      teams = [
        "gov-uk",
        "gov-uk-production-deploy",
        "gov-uk-ithc-and-penetration-testing",
        "national-data-library",
      ]
    }]
  }
}
