# 6. Use Helm for application package management

Date: 2021-08-16

## Status

Accepted

## Context

We require something more sophisticated than handcrafted YAML when defining an application's Kubernetes resources, to ensure that applications can be defined once, and deployed to multiple targets with differing configurations. At a high level, we require a means to define an application's Kubernetes resources as an installable package, with configuration options passed in at deploy time.

There are many options for packaging Kubernetes applictions, including but not limited to:

- [Helm](https://helm.sh)
- [Terraform](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)
- [Pulumi](https://www.pulumi.com/docs/intro/cloud-providers/kubernetes/#pulumi-kubernetes-provider)
- [Skaffold](https://skaffold.dev)

While we are currently using Terraform for AWS infrastructure management, we should maintain a strict separation of concerns between managing cloud infrastructure and the software applications that run on top; using a single tool for both will inevitably lead to blurred lines between the two. In addition, [Terraform's kubernetes support is still quite new](https://www.hashicorp.com/blog/beta-support-for-crds-in-the-terraform-provider-for-kubernetes), and can lag behind Kubernetes itself.

While Kustomize has been adopted into the main Kubernetes project, that decision has [not been without controversy](https://goteleport.com/blog/kubernetes-kustomize-kep-kerfuffle/). Kustomize has also not yet seen wide adoption within the industry, and offers little beyond the basic functions of interpolating values into YAML files.

Helm by comparison has widespread industry adoption, a [large number of existing packages](https://artifacthub.io/packages/search), and widespread support in the wider devops and development ecosystem (e.g. [Github Actions](https://github.com/helm/chart-releaser-action), [CircleCI Orb](https://circleci.com/developer/orbs/orb/circleci/helm), [VS Code extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools), [Terraform provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)).

## Decision

Use Helm v3+.

## Consequences

We can make use of existing Helm charts for supporting tools and services:

- [AWS Load Balancer Controller](https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller)
- [Prometheus + Grafana](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack)
- [Fluentd](https://artifacthub.io/packages/helm/bitnami/fluentd)

While not required at this stage, we will likely want to consider introducing a [Helm chart repository](https://helm.sh/docs/topics/chart_repository/) at some stage in the future.

Helm provides a [release history](https://helm.sh/docs/helm/helm_history/) for an installed chart, and support for [rolling back to previous releases](https://helm.sh/docs/helm/helm_rollback/). Care must be taken when rolling back an application with a dependency on database migrations however.

Helm charts [are versioned](https://helm.sh/docs/topics/charts/#charts-and-versioning), entirely separately from the _application_ version. Care must be taken to avoid confusion between the two, particularly when communicating with chart authors in development teams.

Helm adds Go templates to YAML, and [YAML](https://docs.saltproject.io/en/latest/topics/troubleshooting/yaml_idiosyncrasies.html) [is](https://www.elastic.co/guide/en/beats/libbeat/current/config-file-format-tips.html) [still](https://www.arp242.net/yaml-config.html) [YAML](https://speakerdeck.com/xeraa/yaml-considered-harmful). The wisdom of applying text templating to JSON-derived data structures aside, we should be conscious of YAML idiosyncracies when authoring charts or defining values.

Helm and the many other alternatives are not mutually exclusive, so our adoption of Helm does not prevent the use of any other tools, now or in the future. If development teams wish to adopt Kustomize or Skaffold instead there is nothing in principle to prevent that.
