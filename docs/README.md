# Introduction to GOV.UK infrastructure

## Hosting provider

GOV.UK applications run in containers on a Kubernetes clusters hosted on AWS
Elastic Kubernetes Service (EKS).

A few things also run on Google Cloud Platform (GCP), such as the static mirror
of the website.

### Configuration as code

We use [Terraform] to manage those AWS resources which we don't (yet) manage
via Kubernetes.

This repo holds the Terraform configuration for the EKS clusters and some of
the other AWS services that we use to run GOV.UK.

Some GOV.UK services, such as managed databases and the static www mirrors, are
still managed via the legacy [govuk-aws] and [govuk-aws-data] repositories.

There is a playbook for [deploying a new GOV.UK Kubernetes
environment](create-a-new-environment.md).

### CI/CD

Tests for govuk-infrastructure run in [GitHub Actions](../../../../actions).

[govuk-aws]: https://github.com/alphagov/govuk-aws
[govuk-aws-data]: https://github.com/alphagov/govuk-aws-data
[Terraform]: https://www.terraform.io/
