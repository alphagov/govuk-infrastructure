# 15. Maintain a read-only IAM role

Date: 2026-06-16

## Status

Accepted

## Context

We aim to adhere to the principle of least privilege wherever we can. In the particular case of AWS and Kubernetes
cluster access we do this by providing a set of IAM and Kubernetes roles. Each role grants the permissions needed for
engineers to do routine parts of their jobs. We maintain a separate set of roles with the permissions needed for more 
destructive or sensitive acts that we more tightly gate access to.

<!-- vale RedHat.TermsWarnings = NO -->
Prior to May 2025 we had four roles: `ReadOnly`, `User`, `PowerUser`, and `Admin`. We ran a developer survey and 
discovered that most users were defaulting to using the `PowerUser` role because `ReadOnly` didn't grant them access
to everything they needed. Crucially, it did not grant them access to Amazon Athena. Developers found friction in using 
the`ReadOnly` role for most of their work, only to find they needed to switch roles to use Athena. In the end, most 
developers had begun to assume the `PowerUser` role by default, which granted them additional permissions in excess of 
that they _required_ to do their work.
<!-- Linting rule is mistaking "May" as a synonym for "might" instead of the month -->
<!-- vale RedHat.TermsWarnings = YES -->

In response to this, we elected to retire the `ReadOnly`, `User`, and `PowerUser`roles in favour of new roles whose granted
permissions better reflected those needed by the developers: `Developer`.

We noted that the `Developer` role granted its users the permission to update and delete Kubernetes `Deployment`resources,
making it possible to take running applications offline. `Developer` had become the lowest level of privilege available
to its users, and we felt that the lowest level of privilege should not be capable of causing a production outage.
However, the ability to mutate `Deployment` resources is a valid and useful permission for developers to have.

In June 2025 we reconsidered the need for a `ReadOnly` role.

## Decision

We have decided to reintroduce the `ReadOnly` role to give a fully read-only level of privilege in a number
of scenarios:

1. Developers wanting to just look about without changing anything,
2. Junior/apprentice level roles needing access without the ability to accidentally change anything,
3. External people, such as pen testers, needing access to our AWS accounts.

We feel that the purpose of a read-only role is to give a level of privilege that grants a no greater level of access
than reading the source code would. For that reason, we have chosen to explicitly prevent the `ReadOnly` role from
reading secret values from both AWS SecretsManager and AWS Simple Systems Manager Parameter Store. We have also prevented
it from reading objects within Amazon S3.

We will ensure that engineers can assume the role in the same way as our other roles; either with GDS CLI or using a 
predictable name in the console.

## Consequences

As a consequence of the decisions we've made, we will have an additional role to maintain over time. We believe this is
a minimal burden, and by choosing to prevent its access to secrets and objects in S3 we feel we have further mitigated
any risks it poses.
