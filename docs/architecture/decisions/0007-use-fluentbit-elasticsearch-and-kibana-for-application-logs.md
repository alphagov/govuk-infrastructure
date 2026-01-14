<!-- vale RedHat.Headings = NO -->

# 7. Use Fluent Bit, Elasticsearch and Kibana for application logs

<!-- Title contains proper nouns. Sentence casing irrelevant -->
<!-- vale RedHat.Headings = YES -->

Date: 2021-08-16

## Status

Deprecated (no superseding ADR)

## Context

### Log collection and forwarding

Application containers should output their logs as [`stdout`/`stderr` streams](https://12factor.net/logs), which an aggregator can forward to 
a single log store. These logs should be searchable, filterable, and appropriately tagged.

There are two broad approaches to log collection and forwarding in Kubernetes

- Run a [sidecar container](https://kubernetes.io/docs/concepts/cluster-administration/logging/#sidecar-container-with-logging-agent)
  within each `Pod` to pick up the application's logs from a file or socket and forward them on (this is the only
  available option with [Elastic Kubernetes Service (EKS) Fargate, although partially managed by AWS](https://docs.aws.amazon.com/eks/latest/userguide/fargate-logging.html))
- Run a log collection and forwarder agent on [each node as a `DaemonSet`](https://kubernetes.io/docs/concepts/cluster-administration/logging/#using-a-node-logging-agent)

We must have logging as a service and enable it by default for all containers, so the sidecar pattern does not meet
our needs.

To make application logs searchable and navigable, we require the logging agent to annotate and index logs with
Kubernetes cluster metadata (namespace, pod name, labels, and so on).

The most commonly used logging agents for Kubernetes are: [Fluentd](https://www.fluentd.org) and [Fluent Bit](https://fluentbit.io). 
Fluent Bit is a successor to Fluentd, and aims to be more lightweight and offer better performance, but has a smaller 
plugin ecosystem than Fluentd.

### Log storage and UI

We must store our logs somewhere, with a browser-based UI for searching, filtering, and browsing. There are many
options in the space, but the most common option is [Elasticsearch and Kibana](https://www.elastic.co/what-is/elk-stack).

It is possible that we will ultimately push logs to a GDS-wide central log store, but we should deploy something ourselves 
in the short term. Doing so will ensure we have a usable logging service for our users sooner rather than later, and 
get familiar with the details of logging within Kubernetes ourselves.

For now, the obvious choice is Elasticsearch and Kibana, due to their extensive support for this use case and in this
ecosystem.

## Decision

Use a **Fluent Bit** `DaemonsSet` with AWS Elasticsearch Service.

## Consequences

Fluent Bit is a lighter and faster alternative to Fluentd, with first-class Kubernetes support. It does however have a
smaller plugin ecosystem, although we are unlikely to need any exotic plugins.

Fluent Bit and Fluentd are largely drop-in replacements for each other, so we can quickly and easily change logging
agents if necessary.

Fluent Bit can be quickly deployed with little to no configuration by using the [official Helm chart](https://github.com/fluent/helm-charts).

AWS Elasticsearch Service provides both [Elasticsearch itself, plus Kibana](https://aws.amazon.com/elasticsearch-service/features/).

We must restrict access to Kibana with authentication, ideally with corporate identities. We must explore appropriate 
options for this, for example AWS SSO, or Cognito. Similarly, we might also require authorization and segregation within
Elasticsearch itself.

This ADR covers application-level logging only, not cluster control plane or node or `kubelet` logs. A future ADR will
be cover that.
