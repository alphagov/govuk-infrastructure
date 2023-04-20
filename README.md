# GOV.UK Infrastructure

## What's in this repo

The govuk-infrastructure repo contains Terraform modules for turning up an EKS Kubernetes cluster for GOV.UK.

### What's not in this repo

Helm charts for GOV.UK applications are in [alphagov/govuk-helm-charts](https://github.com/alphagov/govuk-helm-charts).

Base image definitions for GOV.UK Ruby apps are in [alphagov/govuk-ruby-images](https://github.com/alphagov/govuk-ruby-images/).

Some AWS services for GOV.UK are still configured using the legacy [alphagov/govuk-aws](https://github.com/alphagov/govuk-aws/) (public) and [alphagov/govuk-aws-data](https://github.com/alphagov/govuk-aws-data/) (private) repos.

## Usage

To install the [currently-used version of Terraform](terraform/.terraform-version):

```shell
brew install tfenv
cd terraform/
tfenv install
```

## Working on this repo

We have some [recommended pre-commit hooks](.pre-commit-config.yaml). If
you're making changes to this repo, please [install the pre-commit
hooks](https://pre-commit.com/#install) on your machine.

See [alphagov/gds-pre-commit](https://github.com/alphagov/gds-pre-commit) for
more recommendations on using pre-commit.

## Documentation

See the [docs/](docs/) directory.

There are also docs in [terraform/docs/](terraform/docs/) and inline READMEs in some directories.

## Team

[GOV.UK Platform Engineering team](https://github.com/orgs/alphagov/teams/gov-uk-platform-engineering) looks after this repo. If you're inside GDS, you can find us in [#govuk-platform-engineering](https://gds.slack.com/channels/govuk-platform-engineering) or view our [kanban board](https://trello.com/b/u4FCzm53/).

## Licence

[MIT License](LICENCE)
