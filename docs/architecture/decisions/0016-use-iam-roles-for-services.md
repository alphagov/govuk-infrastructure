# 16. Use IAM Roles for External Services and Applications

Date: 2026-06-20

## Status

Proposed (Pending)

## Context

Many services currently use IAM access keys, which are assigned to IAM users and inherit all permissions granted to those users. If these keys are compromised—through leakage or reuse by unauthorised actors, they can pose a significant security risk. Long-lived keys increase this risk, and regular rotation is encouraged to mitigate it.

Many third-party services now support the use of IAM roles, allowing a trust relationship to be established so that external AWS accounts or infrastructure can assume the role and its associated permissions.

For internal applications (hosted within our AWS accounts), AWS access keys are sometimes used to access resources. Where possible, these applications (or their EKS pods) should use EKS Pod Identities or assume IAM roles directly, rather than relying on access keys.


## Decision

We have decided to retire (delete) IAM users and their associated access keys, replacing them with suitable IAM roles. This transition will occur when:

* An access key is identified as "long-lived" and is a candidate for rotation.
* The service using the access key supports assuming IAM roles.
* The application using the access key can adopt an EKS Pod Identity.

This change reduces attack vectors, strengthens our security posture, and aligns with the Principle of Least Privilege (PLP).

One recent example of this change is our work around [reconfiguring Fastly to use IAM Roles instead of Access Keys](https://github.com/alphagov/govuk-infrastructure/issues/2226).

## Consequences

As a result of this decision, we will have fewer access keys to manage and rotate. However, each time we identify a candidate for migration to roles or pod identities, additional work may be required to create or update the necessary IAM roles and permission policies.