# 21. GIve Fastly CNAME records a TTL of 300

Date: 2026-10-27

## Status

Accepted

## Context

GOV.UK uses Fastly as its Content Delivery Network (CDN). Public users don't access GOV.UK servers directly but connect through Fastly. 
`www.gov.uk` is a CNAME record pointing to `www-cdn.production.govuk.service.govuk` which is itself a CNAME record pointing to Fastly. 
`assets.publishing.service.gov.uk` is a CNAME record pointing to Fastly.

In the event that an incident with Fastly occurs we fail over to our backup CDN by pointing both CNAME records to AWS CloudFront.

Currently, the TTLs for these CNAME records are set to 1 hour. This means that in the event of an incident with Fastly it will take up to an hour before service is restored.

## Decision

We have decided to give Fastly CNAME records for `assets.publishing.service.gov.uk` and `www-cdn.production.govuk.service.gov.uk` a TTL of 300.

## Consequences

As a result of this decision, in the event of an incident with Fastly we will be able to fail over to AWS CloudFront and restore service to users quickly.
