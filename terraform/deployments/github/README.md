# GOV.UK GitHub Infrastructure configuration

> **Note**: Currently this module can only be applied by an alphagov GitHub
Organisation Admin.

This module configures GitHub resources (currently just GitHub Action Organisation
Secret Repositories) so that the platform can automatically give permissions to
repositories with specific tags.

We anticipate that teams will add GitHub tags to their repositories (similar to
annotations on Kubernetes resources) to enable platform functionality.
For instance creating an ECR registry and giving permissions to push to the
registry might be enabled with the repo tag `dockerised`.

This module provides similar functionality to the [govuk-saas-config]
repository, which configures repositories with sensible defaults such as
protecting the `main` branch and ensuring the repository is compatible with
our old EC2-based platform (such as checking Jenkins config).
This is noted as [tech debt] and we should migrate govuk-saas-config to this
repository.

Our intent is to replace govuk-saas-config with Terraform configuration.

[govuk-saas-config]: https://github.com/alphagov/govuk-saas-config/tree/master/github/lib
[tech debt]: https://trello.com/c/mojlsebq/226-we-have-two-tools-for-managing-github-resources

## Applying Terraform

**Warning**
Any new resource "github_actions_organization_secret_repositories" that has been
created in the GitHub Web UI before will be overwritten and set to an empty
secret.

1. Generate access token
  1. Go to https://github.com/settings/tokens/new
  2. Create a new token with permissions `admin:org` and `public_repo`
2. Configure Terraform
  ```shell
  gds aws govuk-production-poweruser -- \
    terraform init -backend-config production.backend -upgrade
  ```
3. Plan Terraform
  ```shell
  GITHUB_TOKEN=<token> gds aws govuk-production-poweruser -- terraform plan
  ```
4. Apply Terraform
  ```shell
  GITHUB_TOKEN=<token> gds aws govuk-production-poweruser -- terraform apply
  ```
