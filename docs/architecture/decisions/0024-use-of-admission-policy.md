# 24. Use of admission policy

Date: 2026-08-07

## Status

Accepted

## Context

Starting with Kubernetes version 1.36 Validating and Mutating Admission Policies are enabled by default. Admission Policies are a declarative, in process alternative to admission webhooks. They are appealing because the are more performant and simpler. Policies are quite configurable and they are written with YAML and Common Expression Language (CEL).

The strengths of Admission Policies are:

- native in-process
- reduces admission request latency
- improves reliability and availability
- avoids the operational burden of webhooks
- can mutate resources with access to `userInfo` field in the admission review object

## Decision

Keep using Open Policy Agent (OPA) and Rego.

Pick Gatekeeper and Admission Webhooks over CEL and Admission Policy where possible.

OPA proves particularly useful for the team, as we [expect to utilise the engine](https://concourse-ci.org/docs/operation/opa-integration/) with our upcoming [concourse work](./0018-use-concourse-ci.md).

## Consequences

There are a couple of scenarios where Gatekeeper cannot meet our needs. They are:

- When we need to write a mutation that requires looking up data from the `userInfo` field in the `AdmissionReview` object
- When we need a performant admission

Our choice to prioritise the Gatekeeper, Rego language and the OPA engine means that engineers will have less languages and approaches that they need to hold in their head.

We will stay flexible and still have the option to use Admission Policies when we need, otherwise we'll continue leveraging the efficiency gains of already well known technologies.
