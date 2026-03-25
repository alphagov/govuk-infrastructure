output "deployable_repo_names" {
  description = "List of repositories that can be deployed"
  value       = [for repo in local.deployable_repos : repo.name]
}

output "repository_ids" {
  value = [for repo in github_repository.govuk_repos : repo.id]
}
