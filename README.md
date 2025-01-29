# GOV.UK Infrastructure

## What's in this repo

The govuk-infrastructure repo contains:

- [`terraform/`](terraform/): Terraform modules for turning up an Kubernetes
  cluster on EKS for GOV.UK.
- [`images/`](images/): Container image definitions for utilities such as the _toolbox_ image.
- [`.github/`](.github/): GitHub Actions and workflows used by other GOV.UK
  repos, for example release automation, test runners and security analysis
  tools.

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

## Pre-commit hooks

We have some [recommended pre-commit hooks](.pre-commit-config.yaml). You need
to [install `pre-commit`](https://pre-commit.com/#install) for these to run.

## Documentation

See the [docs/](docs/) directory.

There are also docs in [terraform/docs/](terraform/docs/) and inline READMEs in some directories.

## Team

[GOV.UK Platform Engineering team](https://github.com/orgs/alphagov/teams/gov-uk-platform-engineering) looks after this repo. If you're inside GDS, you can find us in [#govuk-platform-engineering](https://gds.slack.com/channels/govuk-platform-engineering) or view our [kanban board](https://github.com/orgs/alphagov/projects/71).

## Licence

[MIT License](LICENCE)
