# GOV.UK GitHub Infrastructure configuration

This module configures GitHub resources to automatically assign permissions to repositories based on properties defined in a YAML file. For example, setting `can_be_deployed: true` enables features like creating an ECR registry and granting push permissions.

This module:

🧰 Ensures all repositories are configured consistently:
- Visibility, topics, merge settings, branch deletion on merge etc.
- Enables security features like vulnerability alerts
- Prevents archiving if there are open PRs or GitHub Pages are active

🔐 Applies branch protection to the `main` branch for applicable repositories:
- Requires PR reviews
- Supports status checks and code owner reviews
- Defines standard status checks
- Restricts who can push to the `main` branch in line with [GOV.UK Production access rules](https://docs.publishing.service.gov.uk/manual/rules-for-getting-production-access.html).

👥 Manages team access:
- Manages GitHub teams access such as: `GOV.UK`, `GOV.UK CI Bots`, `GOV.UK Production Admin`, `GOV.UK Production Deploy` and `GOV.UK ITHC and Penetration Testing`
- Grants team-based repository access
- Adds access for the CO Platform Engineering team to specific DNS repos

🔑 Grants repositories access to pre-existing organisation-level secrets based on their roles:
- Deployable repos → Argo & CI secrets
- Pact publishers → Pact Broker credentials
- Gem publishers → govuk-ci GitHub API token
- All repos → Slack webhook URL

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

## Creating and configuring a new repository

To create and configure a **new** repository, you will need to raise a Pull Requests to add it to [repos.yml](/terraform/deployments/github/repos.yml) file and apply terraform changes in Terraform Cloud.
You can use the existing repository configurations as examples. For detailed property definitions, refer to the [associated JSON schema](/terraform/deployments/github/schemas/repos.schema.json).

### Configuring required status checks

Use the predefined anchors for consistency. For Ruby on Rails applications use:
```
standard_contexts: *standard_govuk_rails_checks
```

For other software use:
```
standard_contexts: *standard_security_checks
```

When defining additional required checks, make sure workflow jobs have a `name` so they can be referenced directly. _Alternatively, you can reference job IDs._

For workflows which use reusable workflows (these are the ones with `uses` property), the pattern is `<initial_workflow.jobs.job.[name/id]> / <reused-workflow.jobs.job.[name/id]`.
[Example of a job](https://github.com/alphagov/publisher/blob/0bf1bd705c4a05a4df2b616474ea8cb831a049a4/.github/workflows/ci.yml#L54) where initial workflow job name is `Test JavaScript` and the [reused workflow name is `Run Jasmine`](https://github.com/alphagov/govuk-infrastructure/blob/77c3c94abf3f0b9e40125f186219bddfc0ec815a/.github/workflows/jasmine.yml#L1).

[Example of a job defined directly in the ci.yml file](https://github.com/alphagov/publishing-api/blob/f2026bc5873a2f6ab5d7acd3b6522b4b18f18775/.github/workflows/ci.yml#L43-L60)

Example configuration:
```
    required_status_checks:
      standard_contexts: *standard_govuk_rails_checks
      additional_contexts:
        - Test JavaScript / Run Jasmine   # workflow that uses reusable workflows
        - Test Ruby                       # workflow defined directly in the ci.yaml
```

Note that private repositories can't use the predefined `standard_govuk_rails_checks` or `standard_security_checks`. In such cases, include a comment: `# standard security checks are disabled as not configured for a private repo`. You should define equivalent jobs in your repository’s CI workflow and reference them in the `additional_contexts` section of the required status checks.

> 🛠️ If the status checks aren't working once you've configured the CI pipeline in your new repo, ensure that the job names defined in the repos.yml config are matching the names in the ci.yml file in your new repo.

### Private repositories

Private repositories should be treated as exceptions. We should [make new source code open](https://www.gov.uk/service-manual/service-standard/point-12-make-new-source-code-open) in accordance with [point 3 of the Technology Code of Practice](https://www.gov.uk/guidance/the-technology-code-of-practice). Only create a private repository if there are legitimate [grounds for keeping the code closed](https://www.gov.uk/government/publications/open-source-guidance/when-code-should-be-open-or-closed). 

To configure a `private` or `internal` repository, set the `visibility` explicitly: 
```
  visibility: private
```

Note: Private repositories can't use GitHub Actions workflows that upload SARIF files, and therefore can't use the predefined standard security checks.

### Adding existing repositories 

> Skip this step if you are creating a new repository.

To manage an **existing** repository using the GOV.UK GitHub Infrastructure configuration, it needs to be imported into terraform state. Otherwise terraform apply will fail attempting to create a repository that already exists. 

To import the resource, use an import block:
```
import {
  to = github_repository.govuk_repos["govuk-existing-repo-name"]
  id = "govuk-existing-repo-name"
}
```

[Example commit of importing an existing repository](https://github.com/alphagov/govuk-infrastructure/commit/c6774a7d42ca2eb9b0987a51cde8b57e13e0577f). Note that the code only has to run once so it's ok to remove old entries.

If you've manually configured branch protection rules, you'll need to import them using the block below. Alternatively, you can delete the existing rules via the GitHub UI and allow Terraform to recreate them.
```
import {
  to = github_branch_protection.govuk_repos["govuk-existing-repo-name"]
  id = "govuk-existing-repo-name:main"
}
```

### Apply terraform changes

Before merging your Pull Request, review the Terraform plan carefully. 
After the PR is merged, remember to review it again and to apply changes in [Terraform Cloud GitHub workspace](https://app.terraform.io/app/govuk/workspaces/GitHub/runs).


## Archiving repositories

To archive a repository, you will need to raise **two** Pull Requests to update the repository's configuration in the [repos.yml](/terraform/deployments/github/repos.yml) file.

1. Remove all properties

Remove all properties such as `required_status_checks` or `homepage_url`.

```diff
- my-repo:
-  can_be_deployed: true
-  homepage_url: "https://docs.publishing.service.gov.uk/repos/my-repo.html"
-  required_status_checks:
-    standard_contexts: *standard_govuk_rails_checks
-    additional_contexts:
-      - Test Ruby
-      - Lint JavaScript / Run Standardx
-      - Lint SCSS / Run Stylelint
+  my-repo: {}
```

Raise a Pull Request and review the Terraform plan carefully. Once approved, merge the PR. Remember to apply the Terraform changes after reviewing the plan output again in [Terraform Cloud GitHub workspace](https://app.terraform.io/app/govuk/workspaces/GitHub/runs).

2. Add the `archived: true` property

```diff
-  my-repo: {}
+  my-repo:
+    archived: true
```

Raise a Pull Request. Review the Terraform plan carefully.

The Terraform Deployment will run a series of precondition checks to catch any outstanding PRs or unaddressed Github Pages configuration. If you have missed any, the Terraform Plan will fail and you should back go over previous steps in the [Retire a repo](https://docs.publishing.service.gov.uk/manual/retiring-a-repo.html) manual again to make sure nothing has been overlooked.

Once the PR is approved, merge it. Then apply the Terraform changes after reviewing the plan output again in [Terraform Cloud GitHub workspace](https://app.terraform.io/app/govuk/workspaces/GitHub/runs).
