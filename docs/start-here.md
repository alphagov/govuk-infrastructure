# Start here

This document serves as an introduction to GOV.UK's _new_ infrastructure, and
the `govuk-infrastructure` repo that you are now viewing.

**Note:** This repository does not currently manage any production
infrastructure. For the docs for the _current_ infrastructure, please see
[govuk-aws].

## What is this document for

The goal of this document is to describe briefly the design of GOV.UK's
infrastructure and point to other documents that will give you the full picture.

This document may contain forward-looking statements regarding future work
or the expected state of GOV.UK infrastructure. We caution you that such
statements reflect our current expectations and estimates based on factors
currently known to us and that the actual state of the infrastructure could
differ materially.

## What is GOV.UK

GOV.UK is set of services that provides the website www.gov.uk.

## Introduction to GOV.UK infrastructure

### Hosting provider

GOV.UK apps run in containers on AWS Elastic Container Service (ECS) on the
Fargate serverless compute engine.

### Configuration as code

The `govuk-infrastructure` repository holds the configuration for the AWS
services that we use to run GOV.UK.

GOV.UK apps and other services (such as databases) used to run in EC2. For
the old configuration, please see the [govuk-aws] repository.

We use [Terraform] to manage AWS resources.

### CI/CD

Tests for govuk-infrastructure happen in GitHub Actions.

[govuk-aws]: https://github.com/alphagov/govuk-aws
[Terraform]: https://www.terraform.io/
