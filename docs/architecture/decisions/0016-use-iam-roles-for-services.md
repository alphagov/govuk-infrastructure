# 16. Use IAM roles for external services and applications

Date: 2026-06-20

## Status

Accepted

## Context

<!-- vale RedHat.PassiveVoice = NO -->
Many services currently use IAM access keys, which are assigned to IAM users and inherit all permissions granted to
those users. If these keys are compromised through leakage or reuse by unauthorised actors, they can pose a significant
security risk. Long-lived keys increase this risk, and regular rotation is encouraged to mitigate it.
<!-- Passive voice makes sense in this context -->
<!-- vale RedHat.PassiveVoice = YES -->

Many third-party services now support the use of IAM roles. Using IAM roles allows a trust relationship to be 
established so that external AWS accounts or infrastructure can assume the role and its associated permissions.

For internal applications (hosted within our AWS accounts), AWS access keys are sometimes used to access resources.
Where possible, these applications (or their Kubernetes pods) should use Kubernetes `Pod` identities or assume IAM roles
directly, rather than relying on access keys.

## Decision

We have decided to retire (delete) IAM users and their associated access keys, replacing them with suitable IAM roles.
This change will occur when:

* We identify a long-lived access key that is a candidate for rotation.
* The service using the access key supports assuming IAM roles.
* The application using the access key can adopt a `Pod` Identity.

This change reduces attack vectors, strengthens our security posture, and aligns with the Principle of Least Privilege.

One recent example of this change is our work
around [reconfiguring Fastly to use IAM Roles instead of Access Keys](https://github.com/alphagov/govuk-infrastructure/issues/2226).

## Consequences

As a result of this decision, we will have fewer access keys to manage and rotate. However, each time we identify a
candidate for migration to roles or pod identities, we will need to do additional work will to create or manage the 
necessary IAM roles and permission policies.
