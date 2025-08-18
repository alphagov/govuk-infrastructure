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

Configuration of CDN services is stored in [alphagov/govuk-fastly](https://github.com/alphagov/govuk-fastly) and [alphagov/govuk-fastly-secrets](https://github.com/alphagov/govuk-fastly-secrets) (private) repos.

## Usage

To install the compatible version of Terraform:

```shell
brew install tfenv
cd terraform/
tfenv install latest
tfenv use latest
```

We set the constraints with minor version precision. However when using this Terraform version manager, you need to specify the patch version, e.g. `tfenv install 1.10.5`.

## Pre-commit hooks

We have some [recommended pre-commit hooks](.pre-commit-config.yaml). You need
to [install `pre-commit`](https://pre-commit.com/#install) for these to run.

## Documentation

See the [`docs/` directory](docs/).

There are also docs in [the `terraform/docs/` directory](terraform/docs/) and inline in READMEs in some directories.

## Team

[GOV.UK Platform Engineering team](https://github.com/orgs/alphagov/teams/gov-uk-platform-engineering) looks after this repo. If you're inside GDS, you can find us in [#govuk-platform-engineering](https://gds.slack.com/channels/govuk-platform-engineering) or view our [kanban board](https://github.com/orgs/alphagov/projects/71).

## Licence

[MIT License](LICENCE)
