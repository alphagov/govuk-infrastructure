# 23. Use OPA Gatekeeper

Date: 2026-07-07

## Status

Accepted

## Context

We have assessed and made this decision in the context of a piece of work to implement a job request and approvals system
in Kubernetes. However we believe the needs and benefits will be more generally applicable to the platform down the line.

We can state the specific user need we wanted to meet in the discovery as:

> **As a** security conscious engineer building a job request and approval system <br />
> **I want** to prevent a user from requesting and approving their own jobs <br />
> **So that** a malicious user cannot bypass a second human reviewing the content of a job

We can meet our need by making assertions about objects submitted to the Kubernetes API, and rejecting them in the event
they don't meet the criteria.

More generally, the problem we are looking to solve is applying policies to objects beyond those that enforced by 
Kubernetes itself.

The single other requirement we set ourselves for choosing a tool was the ability to perform automated testing of the 
policies in isolation of a full Kubernetes cluster. We want this so that we can treat policy code as we would application
code, with full sets of tests we can trust when making changes in the future.

To that end, we chose to test two tools:
* [Kyverno](https://kyverno.io/)
* [Open Policy Agent (OPA) Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/)

<!-- vale RedHat.PassiveVoice = NO --> 
<!-- "are implemented" is valid in this context -->

Both tools are implementations of Kubernetes' [admissions webhooks](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#what-are-admission-webhooks),
but differ in how they are implemented: Kyverno uses a YAML format, or [CEL](https://cel.dev/) expressions, to express
its policies, whilst OPA Gatekeeper uses [Rego](https://www.openpolicyagent.org/docs/policy-language).

<!-- vale RedHat.PassiveVoice = YES --> 

Both tools were capable of meeting the needs we had.

## Decision

We have chosen to adopt OPA Gatekeeper for applying policy to Kubernetes objects because it is a mature CNCF graduated 
project with good adoption among other Kubernetes users.

We also view its dedicated Rego language as a positive. It is testable, not overly complicated or hard to learn, and 
adopting it meshes well with our [decision to adopt Pkl](./0022-use-pkl-for-configuration.md) as our preferred 
configuration language over YAML.

We also have a number people in the team at the time we've made the decision with strong, positive, open source 
experience of running and working with OPA Gatekeeper. We will be able to accelerate our adoption and maturation
by leaning on their experience and past work.

Finally, choosing OPA Gatekeeper dovetails nicely with our [decision to adopt Concourse](./0018-use-concourse-ci.md), 
because it also makes use of [OPA to implement custom policies](https://concourse-ci.org/docs/operation/opa-integration/).

## Consequences

We will deploy OPA Gatekeeper to all of our Kubernetes clusters. Initially we will deploy it in audit mode, where it 
will report what the outcome of applying a policy would be, without applying it. We will slowly introduce new rules, 
taking good practices rules from trusted sources, until we are confident that enforcing the policies would not have
negative effects.

We also commit to ensuring that each of our policies have suitable test suites.