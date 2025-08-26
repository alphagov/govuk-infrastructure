output "deployable_repo_names" {
  description = "List of repositories that can be deployed"
  value       = keys(local.deployable_repos)
}
