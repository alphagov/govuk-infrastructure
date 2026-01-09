# 17. Retire use of GitHub topics for configuration management

Date: 2026-08-06

## Status

Accepted

## Context

Historically, GOV.UK has used GitHub topic tags to select and configure repositories for things such as enforcing standard
configurations or granting variables (including secrets) to sets of repositories.

An ITHC highlighted this as an issue for several reasons, including:

* Use of topics is not access-controlled or restricted. Anyone who has access to a repository can assign them, making it
  possible to accidentally (or intentionally) bring an unexpected or undesired repository into configuration scope.
* GitHub incidents have resulted in the GitHub search API returning unexpected (or no) results, negatively impacting
  Terraform runs and resulting in the undesired removal of Elastic Container Registry repositories or CodeCommit mirrors.

## Decision

We have decided to stop using GitHub topics as selectors or identifiers for our automation scripts, including
Terraform. As a consequence, we must now configure our GitHub repositories using configuration files or in code 
explicitly, rather than implicitly through remotely-managed tags or labels.

We have documented the changes spurred from this decision have in the [GOV.UK Developer Docs](https://github.com/alphagov/govuk-developer-docs/pull/5187).
They predominantly affect the [GitHub Terraform deployment](https://github.com/alphagov/govuk-infrastructure/tree/main/terraform/deployments/github).

Repository owners can still set topics for the purpose of making repositories easier to filter, search or
organise. However, owners must no longer use them as selectors for automations or scripts.

## Consequences

As a result of this decision:

* We will need to remember to update any Repository configuration changes in code.
* Topics will no longer be able to grant Deployment Secrets to Repositories without oversight.
* Issues affecting the GitHub Search API will no longer risk breaking our Terraform in a way that is unsafe.
