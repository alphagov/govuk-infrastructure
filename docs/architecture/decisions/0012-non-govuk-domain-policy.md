# 12. Non-GOV.UK domain policy

Date: 2025-05-06

## Status

Accepted

## Definitions

This proposal uses the [RFC2119](https://www.ietf.org/rfc/rfc2119.txt) standard for definitions of MUST, MUST NOT and MAY.

Definitions:

- "Authenticated": through an authentication method such as Signon, through [basic access authentication](https://en.wikipedia.org/wiki/Basic_access_authentication), or similar
- "Non-GOV.UK domain": a domain that does not end in `gov.uk`, such as `govuk.digital` or `govuk-internal.digital`. Note that `assets.publishing.service.gov.uk` is considered a GOV.UK domain.

## Context

It is dangerous to have a Non-GOV.UK domain that is publicly routable, without any authentication layer, and which does either of the following:

1. Looks like a GOV.UK site
2. Plays any publicly detectable part in serving content to a GOV.UK site

In either case, the domain might be flagged as a phishing site by systems such as [Google's Safe Browsing](https://transparencyreport.google.com/safe-browsing/search) technology, which is used by browsers including (but not limited to) Chrome to automatically block requests to the site.

At best, this would be an inconvenience, perhaps making it difficult to access internal tooling. At worst, this could cause a major incident, making large parts of GOV.UK inaccessible.

## Proposal

Any web page that lives on a Non-GOV.UK domain, and that is designed to look like a page or service on GOV.UK, MUST either be Authenticated or Unavailable to the Public Internet.

Additionally, the serving of any GOV.UK web page or assets MUST NOT use a Non-GOV.UK domain in any publicly detectable part of the request. Some examples of things to avoid:

1. Using a Non-GOV.UK domain in the redirect chain for a GOV.UK page or asset.
1. Making requests to a Non-GOV.UK domain for 'metadata' associated with a GOV.UK page or asset, e.g. a request for a GOV.UK asset triggering a second request for a favicon from a Non-GOV.UK domain.

To be clear, a Non-GOV.UK domain MAY be used in serving GOV.UK pages or assets, provided the domain in question is not publicly detectable. For example, `govuk-internal.digital` MAY be used under the hood to process a request, provided the domain is not exposed to the browser at any point in the request.
