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

To deploy the root modules, see [Applying Terraform](../terraform/docs/applying-terraform.md).

## GOV.UK apps deployment

GOV.UK apps are deployed by ArgoCD and the config is stored in the
[argocd-apps](https://github.com/alphagov/govuk-helm-charts/tree/main/charts/argocd-apps)
helm chart of the [govuk-helm-charts] GitHub repository.

Please see the [GOV.UK k8s manual website](https://govuk-k8s-user-docs.publishing.service.gov.uk/)
for further details on how to operate the platform.

[govuk-helm-charts]: https://github.com/alphagov/govuk-helm-charts
