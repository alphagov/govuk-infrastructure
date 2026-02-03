module "variable-set-common" {
  source = "./variable-set"

  name     = "common"
  priority = false
  tfvars = {
    dex_github_orgs_teams = [{
      name = "alphagov"
      teams = [
        "gov-uk",
        "gov-uk-ithc-and-penetration-testing",
        "gov-uk-licensing-support",
        "gov-uk-production-deploy",
        "national-data-library",
      ]
    }]
  }
}
