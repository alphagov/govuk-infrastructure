## Notes on using this action

  - This action relies on GOVUK_SLACK_WEBHOOK_URL actions secret being configured for the repository. It’s added to all GOV.UK repositories as an organisation secret in the [GOV.UK GitHub Infrastructure configuration](https://github.com/alphagov/govuk-infrastructure/blob/main/terraform/deployments/github/main.tf)
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
        uses: alphagov/govuk-infrastrtucture/.github/actions/report-run-failure@main
        with:
          slack_webhook_url: ${{ secrets.GOVUK_SLACK_WEBHOOK_URL }}
          channel: your-team-slack-channel
          message: an optional message
```
