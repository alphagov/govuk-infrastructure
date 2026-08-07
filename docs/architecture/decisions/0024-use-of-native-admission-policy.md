# 24. Use of Native Admission Policy

Date: 2026-08-07

## Status

Accepted

## Context

As of kubernetes version 1.36 Validating and Mutating Admission Policies are enabled by default. Admission Policies are a declarative, in process alternative to admission webhooks. They are appealing because the are more performant and simpler. Policies are quite configurable and are written with yaml and Common Expression Language (CEL).

The strengths of Admission Policies are:

- native in-process
- reduces admission request latency
- improves reliability and availability
- avoids the operational burden of webhooks
- can mutate resources with access to `userInfo` field in the admission review object

## Decision

As we already have settled on a more sophisticated policy engine and language in Open Policy Agent (OPA) and Rego, which are used to power [Gatekeeper's](./0023-use-opa-gatekeeper.md) admission controller webhooks, we will commit to writing as much policy as possible using these tools.

OPA proves particularly useful for the team, as we [anticipate utilising the engine](https://concourse-ci.org/docs/operation/opa-integration/) with our upcoming [concourse work](./0018-use-concourse-ci.md).

Where possible we will pick Gatekeeper and admission webhooks over CEL and admission policy.

We will stay flexible and use admission polices when Gatekeeper cannot meet our needs. Examples of such scenarios are:

- When we need to write a mutation that requires looking up data from the `userInfo` field in the `AdmissionReview` object
- When we need a performant admission

## Consequences

Our choice to prioritise the Gatekeeper, Rego language and the OPA engine means that engineers will have less languages and approaches that they need to hold in their head.

We will stay flexible and still have the option to use Admission Policies when we need, simultaneously balancing the efficiency gains of levaraging already well known technologies.
