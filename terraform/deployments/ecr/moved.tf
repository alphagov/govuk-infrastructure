# Moves archived or non-deployable Repos to a new Repo to be removable.
# Delete these after the state change has applied.

moved {
  from = aws_ecr_repository.github_repositories["govuk-graphql"]
  to   = aws_ecr_repository.deleted_repositories["govuk-graphql"]
}

moved {
  from = aws_ecr_repository.github_repositories["govuk-job-request-operator"]
  to   = aws_ecr_repository.deleted_repositories["govuk-job-request-operator"]
}
