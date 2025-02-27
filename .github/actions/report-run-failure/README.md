## Pre-requisites

You will need to get the slack webhook url from the secrets manager first and add it as SLACK_WEBHOOK_URL as a repository secret. 

## Usage example:

Notes: 
  - To minimise noise the slack message is only sent out on the main branch.
  - Typically you will want to report CI errors as part of a deployment workflow. 

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

      # copy lines below to report CI errors to your team channel
      - if: ${{ failure() }}
        uses: alphagov/govuk-infrastrtucture/.github/actions/report-run-failure@main
        with:
          slack_webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
          channel: your-team-slack-channel
          message: an optional message
```