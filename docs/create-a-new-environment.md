# Create a new environment

This document describes how to bring up a new GOV.UK environment called `dev`
using this repository. It gives some reasoning behind the design decisions,
and provides links to other documents that you should read to get the full
picture.

You may also want to look at the document [Create a new workspace][]

See the [Glossary][] for detail on what we mean by an environment.

[Create a new workspace]: ./create-a-new-workspace.md
[Glossary]: ./glossary.md

## Contents

1. Prerequisites
1. Base Deployments
1. Concourse
1. `govuk-publishing-platform` Deployment
1. `monitoring` Deployment

## Prerequisites

This document assumes you have created an isolated AWS account for the new
`dev` environment, and that you have the ability to make changes in that AWS
account, i.e. you can modify IAM users and roles.

It is also assumes that you are somewhat familiar with GOV.UK architecture and
infrastructure. If not, please see the [developer documentation][]. The
[infrastructure manual][] has many guides for operating GOV.UK.

`govuk-infrastructure` is dependent on [govuk-aws][], which creates AWS
resources such as the VPC and the databases for apps in ECS use. Our goal is
to move the resources managed by [govuk-aws][] to this repository. You can check
out the [govuk-aws][] repo and then the [govuk-puppet][] for guidance on how to
bring up the current GOV.UK platform.

[developer documentation]: https://docs.publishing.service.gov.uk/#infrastructure
[infrastructure manual]: https://docs.publishing.service.gov.uk/manual.html#infrastructure
[govuk-aws]: https://github.com/alphagov/govuk-aws
[govuk-puppet]: https://github.com/alphagov/govuk-puppet

## Base Deployments

The terraform code has been structured into deployable units called
[deployments](../terraform/deployments).

Some of these deployments uses variables that are stored
[here](../terraform/deployments/variables). When creating a new environment,
you need to make a copy of one of the existing environment variables directory
(e.g. [test](../terraform/deployments/variables/test)) and modify the files
according to the new environment needs.

Before the deployment of the main
`govuk-publishing-platform` which is the main deployment where GOV.UK apps are
spinned up, there is a need to deployed the following base deployments:
1. [concourse-iam](../terraform/deployments/concourse-iam): creates the IAM role
   that Concourse uses to deploy Terraform in its pipelines
2. [ecr](../terraform/deployments/ecr): creates AWS ECR in the GOV.UK production
   account where container images are stored and gives permissions to other
   AWS accounts to pull these images
3. [terraform-lock](../terraform/deployments/terraform-lock): creates the
   database that Terraform uses to lock the state so that there is no
   conflicting concurrent runs of Terraform
4. [task-runner](../terraform/deployments/task-runner): creates a ECS cluster
   where one-off containers are run to execute a command in the infrastructure,
   e.g. database migration.

For each of the base deployments above (except the `ecr` one), one would have to
create a backend file for the new environment to be spin up. You can use the
existing backend file as a template. Once, the backend file is created, you can
deployed the deployment by following the `Applying` section in the README.md
file.

## Concourse

### Creating a New Concourse Team

Each GOV.UK environment needs to have its own Concourse team where the pipelines
specific for that environment are run.

A new Concourse team (e.g. `govuk-dev`) is created by requesting one from  [reliability-eng](https://reliability-engineering.cloudapps.digital/continuous-deployment.html).

You'll need to add the following team-wide secrets, which are added using the [gds-cli](https://github.com/alphagov/gds-cli), to the new Concourse team:

1. `docker_hub_username`: available in [2ndline password store][] under `docker`
1. `docker_hub_authtoken`: available in [2ndline password store][] under
   `docker`
1. `deploy_apps_slack_webhook`: available in [2ndline password store][] under
   `slack`
1. `govuk_environment`: set to the name of the environment that you are created
1. `concourse-ecr-readonly-user_aws-access-key`
    and  `concourse-ecr-readonly-user_aws-secret-access-key`: create and
    retrieve from the `concourse-ecr-readonly-user` IAM role in AWS console.
    We are currently investigating how to remove the need for these 2 secrets.

[2ndline password store]: https://github.com/alphagov/govuk-secrets/tree/main/pass

### Creating new pipelines

All pipelines are located in [here](../concourse/pipelines) along with their
parameters [here](../concourse/parameters).

When creating a new environment,
you need to make a copy of one of the existing environment parameters directory
(e.g. [test](../concourse/parameters/test)) and modify the files
according to the new environment needs.

## `govuk-publishing-platform` Deployment

Before deploying `govuk-publishing-platform`, we need to set some secrets that
are not generated by the platform in AWS Secrets Manager. The list of secrets
are located [here](../terraform/deployments/govuk-publishing-platform/secrets_manager.tf)

A Concourse pipeline is used to deploy the main `govuk-publishing-platform`
deployment:

```
fly sp -t govuk-<govuk-environment> -p deploy-apps -p concourse/pipelines/deploy.yml \
  -l concourse/parameters/<govuk-environment>/deploy.yml
```

where `<govuk-environment>` is the name of the environment we are
deploying, i.e `dev`.

## Deploying `monitoring` Deployment

Before deploying `monitoring`, we need to set some secrets that
are not generated by the platform in AWS Secrets Manager. The list of secrets
are located [here](../terraform/deployments/monitoring/infra/secrets_manager.tf) and 

A Concourse pipeline is used to deploy the `monitoring`
deployment:

```
fly sp -t govuk-<govuk-environment> -p monitoring -p concourse/pipelines/monitoring.yml \
  -l concourse/parameters/<govuk-environment>/monitoring.yml
```

where `<govuk-environment>` is the name of the environment we are
deploying, i.e `dev`.
