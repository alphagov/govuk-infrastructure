# Report GitHub workflow run failure to Slack

This GitHub Action sends a notification to a nominated Slack channel when a GitHub workflow run fails. The action is typically used to notify a team about critical CI failures on the main branch. It helps to ensure that key issues are addressed quickly by sending relevant information including a direct link to the build logs.

## Notes on using this action

- It is configured with the following inputs:
  -  `slack_webhook_url`: (required) The Slack webhook URL used to send notifications to a specific Slack channel. It's stored as a GitHub secret (GOVUK_SLACK_WEBHOOK_URL), which is added to all GOV.UK repositories as an organisation secret in the [GOV.UK GitHub Infrastructure configuration](https://github.com/alphagov/govuk-infrastructure/blob/main/terraform/deployments/github/main.tf).
  - `channel`: (required) The name of the Slack channel (excluding `#`) where the failure notifications will be sent. 
  - `message`: (optional) A custom message that can be included in the notification to provide additional context. It could include a link to a runbook or documentation.

- To minimise noise, the slack message is only sent out for failures on the main branch.

## Usage example:

The code below indicates where to insert the lines and what lines to copy across.

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
