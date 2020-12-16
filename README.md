**This is a work in progress. This code does not represent production infrastructure yet. For the canonical source of GOV.UK's infrastructure, see [alphagov/govuk-aws](https://github.com/alphagov/govuk-aws) and [alphagov/govuk-puppet](https://github.com/alphagov/govuk-puppet) repos.**

### Usage

To install the [currently used version of Terraform](./terraform/.terraform-version):

```shell
brew install tfenv
cd terraform/
tfenv install
```

### Working on this repo

We have some recommended pre-commit scripts. If you're making changes to this
repo, it's worth setting up the pre-commit hooks on your machine:

[https://pre-commit.com/#install](https://pre-commit.com/#install)

See [alphagov/gds-pre-commit](https://github.com/alphagov/gds-pre-commit) for
more recommendations on using pre-commit.

### Documentation

Further documentation about how to perform various tasks can be found [here](./docs)

### Who we are

We're the GOV.UK Replatforming team, discovering the future of GOV.UK's infrastructure, one line of code at a time. You can find us in #govuk-replatforming on the GDS Slack, and our [(internal) Trello board exists](https://trello.com/b/u4FCzm53/).
