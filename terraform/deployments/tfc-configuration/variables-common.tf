module "variable-set-common" {
  source = "./variable-set"

  name     = "common"
  priority = false
  tfvars = {
    dex_github_orgs_teams = [{
      name  = "alphagov"
      teams = ["gov-uk", "gov-uk-production-deploy"]
    }]
    search_dataform_github_repository_url = "git@github.com:alphagov/search_v2_api_dataform.git"
    search_dataform_github_public_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
    search_dataform_bq_target_projects = [
      "search-api-v2-integration",
      "search-api-v2-staging",
      "search-api-v2-production"
    ]
  }
}
