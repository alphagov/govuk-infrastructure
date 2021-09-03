# Create a new environment

This document describes how to deploy `govuk-infrastructure` into a GOV.UK AWS
account for the first time.

## Prerequisites

You will need an AWS account for the new environment, and admin access to that
account.

`govuk-infrastructure` depends on [govuk-aws] for some AWS resources and
essential services such as the VPC, databases, message queues and so on.
Eventually all these resources will move to this repository. Until then,
`govuk-infrastructure` needs to be deployed into an existing GOV.UK AWS account
containing the old EC2/[Puppet][govuk-puppet] stack.

[govuk-aws]: https://github.com/alphagov/govuk-aws
[govuk-puppet]: https://github.com/alphagov/govuk-puppet

## Terraform

The Terraform code is organised into several [root
modules](https://www.terraform.io/docs/language/modules/#the-root-module),
which we call [deployments](../terraform/deployments).

Some of these deployments require external [tfvars
files](../terraform/deployments/variables). To create a new environment, you
will need to copy the variables directory for an existing environment (e.g.
[integration](../terraform/deployments/variables/integration)) and modify as
appropriate.


There are some dependencies between the root modules. The order to deploy them is:

1. [`concourse-iam`](../terraform/deployments/concourse-iam): creates the IAM role
   that Concourse uses to deploy Terraform in its pipelines
1. [`ecr`](../terraform/deployments/ecr): creates the ECR container registry from
   which the cluster (and Concourse) pull container images. There is a single
   registry for all of the environments (to avoid consistency problems with
   image tags and having to copy images between registries), so this module is
   not deployed per-environment.
1. [`terraform-lock`](../terraform/deployments/terraform-lock): creates the
   DynamoDB table which Terraform uses to control concurrent access to the
   state files in S3.
1. [`cluster-infrastructure`](../terraform/deployments/cluster-infrastructure)
   is normally run by the [`eks` Concourse pipeline][eks-concourse] and creates
   the AWS resources for the cluster.
1. [`cluster-services`](../terraform/deployments/cluster-services) is normally
   run by the [`eks` Concourse pipeline][eks-concourse] and deploys the base
   services into the cluster.

Each these root modules (except `ecr`) requires a [backend config
file](https://www.terraform.io/docs/language/settings/backends/configuration.html#partial-configuration)
You can use an existing backend file as a template.

To deploy the root modules, see [Applying Terraform](../terraform/docs/applying-terraform.md).

[eks-concourse]: ../concourse/pipelines/eks.yml

## Concourse

### Creating a New Concourse Team

Each GOV.UK environment needs to have its own Concourse team where the pipelines
specific for that environment are run.

Request a new Concourse team (e.g. `govuk-staging`) from [reliability-eng](https://reliability-engineering.cloudapps.digital/continuous-deployment.html).

Add the following team-wide secrets to the new team using [gds-cli](https://github.com/alphagov/gds-cli):

1. `docker_hub_username`: available in [2nd-line password store] under `docker`
1. `docker_hub_authtoken`: available in [2nd-line password store] under
   `docker`
1. `deploy_apps_slack_webhook`: available in [2nd-line password store] under
   `slack`
1. `govuk_environment`: set to the name of the environment
1. `concourse-ecr-readonly-user_aws-access-key`
    and `concourse-ecr-readonly-user_aws-secret-access-key`: retrieve from the
    `concourse-ecr-readonly-user` IAM role (via the AWS console) after
    deploying the `concourse-iam` Terraform module.
    We hope to remove the need for these two secrets via EC2 IAM roles.

[2nd-line password store]: https://github.com/alphagov/govuk-secrets/tree/main/pass

### Creating new pipelines

Concourse pipelines and parameters are located in [../concourse](../concourse).

Copy one of the existing parameters directories and modify as appropriate.

## `govuk-publishing-platform` Deployment

There are some [Secrets Manager
secrets](../terraform/deployments/govuk-publishing-platform/secrets_manager.tf)
which are not generated automatically. Create these secrets before running the
Concourse pipeline for the first time.

Create the concourse pipeline which will deploy the cluster and the base cluster services:

```
fly sp -t govuk-<govuk-environment> -p eks -p concourse/pipelines/eks.yml \
  -l concourse/parameters/<govuk-environment>/eks.yml
```

where `<govuk-environment>` is the name of the environment, for example `staging`.
