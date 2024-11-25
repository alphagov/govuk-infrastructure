# 7. Use fluentbit, elasticsearch and kibana for application logs

Date: 2021-08-16

## Status

Accepted

## Context

### Log collection and forwarding
Application containers should output their logs as [`stdout`/`stderr`](https://12factor.net/logs) streams, which can then be forwarded by an aggregator to a single log store. These logs should be searchable, filterable and appropriately tagged with application/component etc.

There are two broad approaches to log collection and forwarding in Kubernetes

- Run a [sidecar container](https://kubernetes.io/docs/concepts/cluster-administration/logging/#sidecar-container-with-logging-agent) with each `Pod` or container to pick up the application logs from a file or socket and forward on (this is the only available option with [EKS Fargate, although partially managed by AWS](https://docs.aws.amazon.com/eks/latest/userguide/fargate-logging.html))
- Run a log collection and forwarder agent on [each node as a `DaemonSet`](https://kubernetes.io/docs/concepts/cluster-administration/logging/#using-a-node-logging-agent)

Logging should be provided as a service and enabled by default for all containers, so the sidecar pattern does not meet our needs.

For application logs to be searchable and navigable we require the logging agent to annotate and index logs with kubernetes cluster metadata (namespace, pod name, labels etc).

The most commonly used logging agents for Kubernetes are: [fluentd](https://www.fluentd.org) and [fluentbit](https://fluentbit.io). Fluentbit is a successor to fluentd, and aims to be more lightweight and offer higher performance, but has a smaller plugin ecosystem than fluentd.


### Log storage and UI
Logs must also be stored somewhere, with a browser-based UI for searching, filtering and browsing. There are many options in the space, but the most common option is [elasticsearch and kibana](https://www.elastic.co/what-is/elk-stack).

We may ultimately push logs to a GDS-wide central log store, but should deploy something ourselves in the short term so that we can provide a usable logging service to users sooner rather than later, and get familiar with the details of logging within Kubernetes ourselves.

For now, the obvious choice is Elasticsearch and Kibana, due to their extensive support for this use case and in this ecosystem.

## Decision

Use a **fluentbit** Daemonset with AWS Elasticsearch Service.

## Consequences

fluentbit is a lighter and faster alternative to fluentd, with first-class Kubernetes support. It does however have a smaller plugin ecosystem, although we are unlikely to need any exotic plugins.

fluentbit and fluentd are largely drop-in replacements for each other, so we can quickly and easily change logging agents if necessary.

fluentbit can be quickly deployed with little to no configuration using the [official Helm chart](https://github.com/fluent/helm-charts).

AWS Elasticsearch Service provides both [Elasticsearch itself, plus Kibana](https://aws.amazon.com/elasticsearch-service/features/).

Kibana access must be restricted via authentication, ideally with corporate identities. Appropriate options for this (AWS SSO, Cognito, etc) must be explored. Similarly, authorization and segregation within Elasticsearch may also be required.

This ADR covers application-level logging only, not cluster control plane or node/kubelet logs. This will be covered in a future ADR.
