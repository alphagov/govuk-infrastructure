# Report GitHub workflow run failure to Slack

This GitHub Action sends a notification to a nominated Slack channel when a GitHub workflow run fails. The action is typically used to notify a team about critical CI failures on the main branch. It helps to ensure that key issues are addressed quickly by sending relevant information including a direct link to the build logs.

The Slack message includes "The https://github.com/alphagov/repo-name failed on main." text and a "Check the build logs" button with a link to the logs.

## Notes on using this action

- It is configured with the following inputs:
  -  `slack_webhook_url`: (required) The Slack webhook URL used to send notifications to a specific Slack channel. It's stored as a GitHub secret (GOVUK_SLACK_WEBHOOK_URL), which is added to all GOV.UK repositories as an organisation secret in the [GOV.UK GitHub Infrastructure configuration](https://github.com/alphagov/govuk-infrastructure/blob/main/terraform/deployments/github/main.tf).
  - `channel`: (required) The name of the Slack channel (excluding `#`) where the failure notifications will be sent. 
  - `message`: (optional) A custom message that can be included in the notification to provide additional context. It could include a link to a runbook or documentation. Note that the default message will appear above this one.

- To minimise noise, the slack message is only sent out for failures on the main branch.

## Usage example:

The code below indicates where to insert the lines and what lines to copy across.

- If you want to be notified about a single job failing

```
name: Always failing job
on:
  workflow_dispatch:

jobs:
  failed-run:
    name: Failed run
    runs-on: ubuntu-22.04
    steps:
      - name: Always failing
        run: exit 1

      # copy lines below to report a github failure to your team channel
      - if: ${{ failure() }}
        uses: alphagov/govuk-infrastructure/.github/actions/report-run-failure@main
        with:
          slack_webhook_url: ${{ secrets.GOVUK_SLACK_WEBHOOK_URL }}
          channel: your-team-slack-channel
          message: an optional message
```

- If you want to be notified of a failure in a workflow that includes multiple jobs

```
name: CI

on:
  workflow_dispatch: {}
  push:
    branches:
      - main
  pull_request:

jobs:
  codeql-sast:
    name: CodeQL SAST scan
    uses: alphagov/govuk-infrastructure/.github/workflows/codeql-analysis.yml@main
    permissions:
      security-events: write

  dependency-review:
    name: Dependency Review scan
    uses: alphagov/govuk-infrastructure/.github/workflows/dependency-review.yml@main

  test-features:
    name: Test features
    uses: ./.github/workflows/cucumber.yml
  
  # copy lines below
  notify-slack-if-failure-on-main:
    runs-on: ubuntu-latest
    steps:
      - name: Notify Slack if failure on main
        if: ${{ failure() }}
        uses: alphagov/govuk-infrastructure/.github/actions/report-run-failure@main
        with:
          slack_webhook_url: ${{ secrets.GOVUK_SLACK_WEBHOOK_URL }}
          channel: your-team-slack-channel
```
