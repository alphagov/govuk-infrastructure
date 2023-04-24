resource "aws_codecommit_repository" "govuk" {
  for_each = data.github_repository.govuk

  repository_name = each.value.name
  default_branch  = "main"
}
