# GOV.UK Infrastructure

## What's in this repo

The govuk-infrastructure repo contains:

- [`terraform/`](terraform/): Terraform modules for turning up an Kubernetes
  cluster on EKS for GOV.UK.
- [`images/`](images/): Container image definitions for utilities.
- [`.github/`](.github/): GitHub Actions and workflows used by other GOV.UK
  repos, for example release automation, test runners and security analysis
  tools.

### What's not in this repo

Helm charts for GOV.UK applications are in [alphagov/govuk-helm-charts](https://github.com/alphagov/govuk-helm-charts).

Base image definitions for GOV.UK Ruby apps are in [alphagov/govuk-ruby-images](https://github.com/alphagov/govuk-ruby-images/).

Configuration of CDN services is stored in [alphagov/govuk-fastly](https://github.com/alphagov/govuk-fastly) and [alphagov/govuk-fastly-secrets](https://github.com/alphagov/govuk-fastly-secrets) (private) repos.

Toolbox utility is stored in [alphagov/govuk-toolbox-image](https://github.com/alphagov/govuk-toolbox-image)

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

## Documentation linting

This repository uses [Vale](https://vale.sh/) to lint our written English prose. Vale applies a variety of rules and 
heuristics, such as avoiding overly long sentences and not using the passive voice, as well as doing spelling and grammar
checks.

To run the documentation linting locally, run 

```shell
make lint_docs
```

### Installing Vale

If you are using a Mac, you can install Vale with Brew:

```shell
brew install vale
```

If you are using Linux or Windows, [refer to Vale's own guide](https://vale.sh/docs/install).

### Resolving common issues with Vale

When using Vale, you will come across a number of common issues and scenarios. Documented here are the scenarios and 
how to handle them

#### Vale says a product name or a plural acronym is an incorrect spelling

Vale uses an open source dictionary to spell check our work. It does not know about proper nouns, and will frequently
ask if you meant to spell it that way. If you are confident that you are right, there are two steps to take

1. Add the word to the vocabulary file in alphabetical order `.vale/styles/config/vocabularies/PlatformEngineering/accept.txt`. 
   You can use limited regular expressions such as `foos?` to match both `foo` and `foos` in a single entry.

2. If the word is the name of a product, add it the `PlatformEngineering.ProductNames` rule in 
   `.vale/styles/PlatformEngineering/ProductNames.yml`. This Vale rule enforces us using the correct spelling of a product
   name by matching common or potential misspellings using regular expressions, and suggesting the correct spelling. Using
   the AWS service CloudWatch as an example, common misspellings include `cloudwatch`, `Cloudwatch`, and `Cloud watch`.
   To match all of these and suggest the correct spelling, add an entry such as this:
   ```yaml
   - "[cC]loud ?[wW]atch": CloudWatch
   ```

#### Vale says a common acronym should be defined

We have a Vale rule that requires acronyms to be defined the first time it's used in a document. For example, instead 
of `IAM` we should write `Identity and Access Management (IAM)` the first time, then just `IAM` later. 

However, there are exceptions to that rule in two places:

1. The rule's definition in `.vale/styles/GOVUK/Acronyms.yml`. This list contains acronyms we think would be well known
   to the general public, such as BBC or CCTV. The list is drawn from the official GOV.UK writing style guide.

2. The vocabulary file in `.vale/styles/config/vocabularies/PlatformEngineering/accept.txt`. This list contains acronyms
   that we think would be well known to somebody reading our documentation, such as HTTPS or CLI.

If you think the acronym would be well known to either of these groups, add it to the correct list.

#### Vale is reporting an error that is wrong in context

Vale can sometimes be wrong about our writing. It is imperfect. For example, it will report not using sentence casing in
a title as an error when the title contains proper nouns. 

You can turn off a rule for a paragraph the offending line or paragraph with a comment containing the rule name:

```markdown
<!-- vale RedHat.Headings = NO -->
# This heading as a Proper Noun and is not sentence cased
<!-- The heading contains proper nouns and should not be sentence case -->
<!-- vale RedHat.Headings = YES -->
```

Comments with the vale directive must have nothing else in the same comment. 

The comment before the rule is turned back on, which explains why the rule is not necessary, is not required. However,
it is a good convention for you to follow.

#### Add a new linting rule

You can create a new linting rule by adding a YAML file in one of two places: `.vale/styles/GOVUK/` and 
`.vale/styles/PlatformEngineering`. The former contains rules that match the rules of the official GOV.UK writing style
guide, and the latter contains additional rules for our own writing.

You should refer to [the checks section of the official Vale documentation](https://vale.sh/docs) for the structure and
format of rules files.

## Team

[GOV.UK Platform Engineering team](https://github.com/orgs/alphagov/teams/gov-uk-platform-engineering) looks after this repo. If you're inside GDS, you can find us in [#govuk-ask-platform-engineering](https://gds.slack.com/channels/govuk-platform-engineering) or view our [kanban board](https://github.com/orgs/alphagov/projects/71).

## Licence

[MIT License](LICENCE)
