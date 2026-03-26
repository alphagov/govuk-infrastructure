# `extract-content-from-editions.sql`

This query extracts the govspeak and/or HTML content of editions, according to their
[`schema_name`](https://docs.publishing.service.gov.uk/content-schemas.html). If only govspeak is available, then it is rendered into HTML.  Then plain text and various HTML tags are extracted from the HTML content.

[Not all schemas are supported](https://docs.google.com/spreadsheets/d/16AoHrcp5Wn9gyEhLFf1psPNJYn59VX0WEzNN7u54CZM/edit#gid=190179367).  Ones that aren't supported are usually ones that don't contain anything resembling "content".  Some of the ones that aren't supported contain links to other documents, so it would be good to extract those links one day to support the 'link search' function in the GovSearch app.

Intermediate steps are stored in tables for subsequent processing, such as extracting elements of HTML.

## Rendering govspeak to HTML

[GovSpeak](https://github.com/alphagov/govspeak) is a markdown extension for GOV.UK editors, implemented in a Ruby gem.

Some GovSpeak is rendered to HTML before it is received by the Publishing API. Most GovSpeak is rendered between the Publishing API and the Content API. Because not all GovSpeak is rendered by the same app, it might not be rendered by the same version of the GovSpeak ruby gem.

We define a BigQuery remote function that calls a Cloud Function that is implemented in Cloud Run, which hosts a docker image containing the GovSpeak ruby gem. See the implementation in the [initial pull request](https://github.com/alphagov/govuk-knowledge-graph-gcp/pull/561).

Theoretically BigQuery and Cloud Run automatically scale to render govspeak in bulk on hundreds of thousands of documents, but in practice it isn't very quick. Not as many instances of the virtual machine are created as are configured, and some of them are idle some of the time.  This doesn't matter much, because on most days there are only a handful of new editions to render.  In a test, a hundred thousand documents were rendered in 20 minutes.
