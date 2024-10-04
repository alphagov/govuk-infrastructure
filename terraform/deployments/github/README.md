# GOV.UK GitHub Infrastructure configuration

> **Note**: Currently this module can only be applied by an alphagov GitHub
Organisation Admin.

This module configures GitHub resources (currently just GitHub Action Organisation
Secret Repositories) so that the platform can automatically give permissions to
repositories with specific tags.

We anticipate that teams will add GitHub tags to their repositories (similar to
annotations on Kubernetes resources) to enable platform functionality.
For instance creating an ECR registry and giving permissions to push to the
registry might be enabled with the repo tag `container`.

This module configures repositories with sensible defaults such as
protecting the `main` branch and ensuring the repository is compatible with
our old EC2-based platform (such as checking Jenkins config).

## Applying Terraform

1. Generate access token, needs to be a GitHub admin for `alphagov` org
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

## Removing repositories

Before an archived repository can be removed from GOV.UK GitHub configuration, it needs to be manually removed from terraform state. 

> Failing to do so will result in repository being deleted (rather than archived). If a repository is not removed by following those steps, it will be un-archived when the GitHub configuration is applied. 

### 1. Remove relevant resource instances from terraform state

Run the following commands to remove resource instances relevant to the retired repository:

```
cd terraform/deployments/github
terraform login
terraform init
terraform state rm 'github_branch_protection.govuk_repos["repo-name"]' &&
terraform state rm 'github_team_repository.govuk_repos["repo-name"]' &&
terraform state rm 'github_team_repository.govuk_production_admin_repos["repo-name"]' &&
terraform state rm 'github_team_repository.govuk_ci_bots_repos["repo-name"]' &&
terraform state rm 'github_repository.govuk_repos["repo-name"]' &&
terraform state rm 'aws_codecommit_repository.govuk_repos["alphagov/repo-name"]'
```

You can verify what other instances need to be removed by running:
```
terraform state list | grep repo-name
```

### 2. Raise a PR to remove repo from `deployments/github/repos.yml`

Ensure terraform plan shows "No changes" before merging the PR.