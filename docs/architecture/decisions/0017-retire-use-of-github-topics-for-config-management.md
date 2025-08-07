# 17. Retire Use of GitHub Topics for Config Management

Date: 2026-08-06

## Status

Accepted

## Context

Historically, GOV.UK has used GitHub Topic Tags (like labels) in order to select and configure multiple Repositories for things such as enforcing standard configurations or granting variables (including secrets) to sets of Repositories.

This has been highlighted as an issue for several reasons, including:

* Use of Topics is not access-controlled or restricted - they can be assigned by anyone who has access to a Repository, making it possible to accidentally (or intentionally) bring an unexpected or undesired repo into configuration scope.
* GitHub incidents have resulted in the GitHub Search API returning unexpected (or no) results, negatively impacting Terraform runs and resulting in the undesired removal of ECR Repositories or CodeCommit mirrors.

## Decision

We have decided to stop using GitHub Topics as selectors or identifiers for our automation scripts (including Terraform). As a consequence, we must now configure our GitHub Repositories using configuration files or in code, explicitly rather than implicitly through remotely-managed tags or labels.

The changes spurred from this decision have been documented in the [GOV.UK Developer Docs](https://github.com/alphagov/govuk-developer-docs/pull/5187) and predominantly affect the 
[Github Terraform Deployment](https://github.com/alphagov/govuk-infrastructure/tree/main/terraform/deployments/github).

Topics can still be set by Repository owners for the purpose of making Repositories easier to filter, search or organise, however, must no longer be used as selectors for automations or scripts.

## Consequences

As a result of this decision:

* We will need to remember to update any Repository configuration changes in code.
* Topics will no longer be able to grant Deployment Secrets to Repositories without oversight.
* Issues affecting the GitHub Search API will no longer risk breaking our Terraform in a way that is unsafe.
