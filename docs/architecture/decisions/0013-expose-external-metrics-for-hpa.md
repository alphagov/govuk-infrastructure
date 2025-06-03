# 13. Expose external metrics for HPA via Prometheus Adapter

Date: 2025-06-03

## Status

Pending

## Context

Kubernetes HPAs on GOV.UK currently scale only on CPU / memory via `metrics-server`.
Several workloads (starting with Chat AI) need to scale on application-level signals such as Sidekiq queue backlog. Kubernetes requires these signals to be available through the `external.metrics.k8s.io` API group.

Prometheus already scrapes the backlog metric (`sidekiq_queue_backlog{job="govuk-chat-worker"}`) in every cluster, but the cluster lacks a component that translates Prometheus data into the external-metrics API.

## Decision

* Adopt the **Prometheus Adapter** Helm chart (`prometheus-community/prometheus-adapter`) as the standard way to serve external metrics.

* Deploy the chart in the **monitoring** namespace and manage it via our existing GitOps repo (`govuk-helm-charts`) and Argo CD.

* Provide a minimal external-metrics rule set per environment; first rule:

  ```yaml
  seriesQuery: 'sidekiq_queue_backlog{job="govuk-chat-worker"}'
  name: { as: ai_sidekiq_queue_backlog }
  resources:
    overrides:
      namespace: { resource: namespace }
  metricsQuery: |
    max(sidekiq_queue_backlog{job="govuk-chat-worker"})
  ```

* Roll out progressively: **integration → staging → production**, validating APIService health (`Available=True`) and metric availability at each stage. We've only deployed the adapter in integration so far. When this ADR is discussed and approved, we will proceed with the rollout.

* Keep default rules disabled (`rules.default: false`) to avoid flooding Prometheus with queries.

* Rely on the adapter’s native config (no `--enable-external-metrics` flag is required in v0.12+)—the presence of `externalRules:` is sufficient.

## Consequences

### Positive

* Application teams can configure HPAs on any Prometheus-exposed metric with only a Namespace label, unlocking finer-grained, workload-specific scaling.
* Approach is CNCF-standard, requires no custom controllers, and fits our existing fork-less Helm + Argo workflow.
* Adapter pods are lightweight; one replica per cluster adds < 100 MiB RSS and negligible CPU.

### Negative / Risks

* Mis-configured rules can crash the adapter (fatal on invalid `resource` names) and take the APIService down. **Mitigation:** PR checks and chart tests.
* Additional Prometheus queries every `metricsRelistInterval` (default 1 min). **Mitigation:** keep rules focused; monitor Prometheus CPU.
* Production HPAs based on poor signals could over- or under-scale services. **Mitigation:** gated rollout, conservative target values, clear runbooks.

### Follow-ups

* Add documentation and a snippet showing how to write new `externalRules`.
* Consider bumping adapter replicas to 2 in production for HA.
* Evaluate whether any default resource-metrics support (kube-top style) is worth enabling later.
