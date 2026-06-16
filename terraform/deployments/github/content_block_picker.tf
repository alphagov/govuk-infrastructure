moved {
  from = github_repository.govuk_repos["content-block-editor"]
  to   = github_repository.govuk_repos["content-block-picker"]
}

moved {
  from = aws_codecommit_repository.govuk_repos["alphagov/content-block-editor"]
  to   = aws_codecommit_repository.govuk_repos["alphagov/content-block-picker"]
}

moved {
  from = github_team_repository.govuk_ci_bots_repos["content-block-editor"]
  to   = github_team_repository.govuk_ci_bots_repos["content-block-picker"]
}

moved {
  from = github_team_repository.govuk_production_admin_repos["content-block-editor"]
  to   = github_team_repository.govuk_production_admin_repos["content-block-picker"]
}

moved {
  from = github_team_repository.govuk_production_deploy_repos["content-block-editor"]
  to   = github_team_repository.govuk_production_deploy_repos["content-block-picker"]
}

moved {
  from = github_team_repository.govuk_repos["content-block-editor"]
  to   = github_team_repository.govuk_repos["content-block-picker"]
}

moved {
  from = github_branch_protection.govuk_repos["content-block-editor"]
  to   = github_branch_protection.govuk_repos["content-block-picker"]
}

moved {
  from = github_repository_dependabot_security_updates.govuk_repos["content-block-editor"]
  to   = github_repository_dependabot_security_updates.govuk_repos["content-block-picker"]
}

moved {
  from = github_repository_vulnerability_alerts.govuk_repos["content-block-editor"]
  to   = github_repository_vulnerability_alerts.govuk_repos["content-block-picker"]
}