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

1. [`ecr`](../terraform/deployments/ecr): creates the ECR container registry from
   which the cluster pull container images. There is a single registry for all
   of the environments (to avoid consistency problems with image tags and
   having to copy images between registries), so this module is not deployed
   per-environment.
1. [`terraform-lock`](../terraform/deployments/terraform-lock): creates the
   DynamoDB table which Terraform uses to control concurrent access to the
   state files in S3.
1. [`cluster-infrastructure`](../terraform/deployments/cluster-infrastructure)
   creates the AWS resources for the cluster.
1. [`cluster-services`](../terraform/deployments/cluster-services)
   deploys the base services into the cluster.
1. [`govuk-publishing-infrastructure`](../terraform/deployments/govuk-publishing-infrastructure)
   creates AWS resources specific to the GOV.UK apps where we are not yet
   able to manage those resources via Kubernetes.

Each these root modules (except `ecr`) requires a [backend config
file](https://www.terraform.io/docs/language/settings/backends/configuration.html#partial-configuration)
You can use an existing backend file as a template.

To deploy the root modules, see [Applying Terraform](../terraform/docs/applying-terraform.md).


## `cluster-services` deployment

There are some [prerequisite secrets](prerequisite-secrets.md)
which are not generated automatically. Create these secrets before running
`terraform apply` for the first time.
