output "deployable_repo_names" {
  description = "List of repositories that can be deployed"
  value       = [for repo in local.deployable_repos : repo.name]
}
