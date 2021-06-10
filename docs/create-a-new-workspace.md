# Create a new workspace

This document describes how to bring up a new GOV.UK workspace called `personal`
using this repository.

You may also want to look at the document [create a new environment][]

See the [Glossary][] for detail on what we mean by an environment and workspace.

## Contents

1. What are workspaces for
1. What a workspace gets you
1. How to create a workspace

## What are workspaces for

Workspaces are for testing changes to `govuk-infrastructure` in an independent
namespace with resources that are somewhat isolated from other workspaces
(including the `default` workspace).

When you [create a new environment][] the default Terraform workspace called
`default` will be used. In Terraform config we use the namespace `ecs`
for the `default` workspace. Please don't create the workspace `ecs`, it
would wreak havoc.

See the document on [Namespaces, DNS, and GOV.UK Replatforming](https://docs.google.com/document/d/1QpFPXRSqzWYefl7a9MmAH_9QuHAcwmMxgvftRwZbPCc/edit)
for more details on namespaces.

Workspaces are only expected to be used in the `test` environment. Please
don't create workspaces in `integration`, `staging`, or `production`.

## What a workspace gets you

A workspace will contain all of the resources that the deployment
`govuk-publishing-platform` creates. This includes:

* A cluster of GOV.UK apps running in isolation
* A signon instance with Signon OAuth apps, unique bearer tokens etc.
* DNS records that allow you to use your apps at their namespace, e.g.
  * www-origin.<workspace-name>.test.govuk.digital
  * publisher.<workspace-name>.test.govuk.digital
* Redis and other backing services that will only be used by your apps.

Not everything is isolated. All other resources created outside of the
`govuk-publishing-platform` deployment are shared across workspaces. This
includes databases managed by `govuk-aws` (no need to clone data across
workspaces, but also don't drop the db or you'll impact other workspaces).

## How to create a workspace

Create a new branch

```
git checkout -b <githubusername>/workspace
```

Change the contents of `concourse/parameters/deploy-parameters.yml` to the
following:

```
workspace: <workspace-name>
# so the pipeline uses your branch (crucially the set_pipeline step will use
# this file!)
govuk_infrastructure_branch: <githubusername>/workspace
# so you don't create noise in the govuk-deploy-alerts channel
disable_slack_channel_alerts: true
```

Commit the new `deploy-parameters.yml` and push your branch to GitHub.

```
git add concourse/parameters/deploy-parameters.yml
git commit
git push --set-upstream origin <githubusername>/workspace
```

Log into Concourse and update the `fly` command if necessary.

```
fly -t govuk-test login --team-name govuk-test --concourse-url https://cd.gds-reliability.engineering
fly -t govuk-test sync
```

Finally, set the pipeline, and then unpause it

```
fly sp -t govuk-test -p deploy-apps-<workspace-name> \
-c concourse/pipelines/deploy.yml \
-l concourse/parameters/deploy-parameters.yml

fly up -t govuk-test -p deploy-apps-<workspace-name>
```

See also the doc on [creating a new concourse pipeline](../concourse/docs/creating_new_deploy_concourse_pipeline.md)

The pipeline should create your workspace. Give it about an hour.

If you see anything broken in this process please at least flag it to the
govuk-replatforming team, or fix it for the next person! Likewise, the same
goes for this doc.

## Can I apply terraform locally?

YES! Though, if you want your workspace to function properly, you'll use the
Concourse pipeline for the initial terraform apply. It does extra stuff like
create secrets for apps.

For the most robust experience, use your Concourse pipeline to apply every time.

## How can I prevent my workspace breaking

Frequently rebase against the `main` branch, to avoid missing out on fixes
or falling too far behind and making it hard to rebase later.

[create a new environment]: ./create-a-new-environment.md
[Glossary]: ./glossary.md
