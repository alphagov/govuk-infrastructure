# Adding an App

It has been [decided](../../docs/architecture/decisions/0006-use-helm-for-application-package-management.md)
to use [Helm v3](https://helm.sh/docs/) to package GOV.UK apps for our
Kubernetes platform.

A Helm charts for the apps are located under the [helm](../helm) directory.

## Creating an App

After installing [Helm v3](https://helm.sh/docs/intro/quickstart/), it is
typical to use `helm create <app_name>` to create a template app that is then
customized for a given GOV.UK app.

For a typical non-internet facing app, the helm directory structure is:
```
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── \_helpers.tpl
│   ├── NOTES.txt
└── values.yaml
```

For an internet facing app, there will be an additional `ingress.yaml` template
file to configure the AWS load balancer that will direct traffic to that app.

## Operations

After creating an app, the following operations can be done
(note that you need to have AWS credentials loaded e.g.
 `eval $(gds aws govuk-test-admin)`):

1. test the config that Helm will generate for Kubernetes:
```sh
<chart_directory>$ helm template .
```

2. validate the Helm chart Kubernetes files against the Kubernetes schemas using
a plugin such as [kubeval](https://github.com/instrumenta/helm-kubeval):
```sh
helm plugin install https://github.com/instrumenta/helm-kubeval
<chart_directory>$ helm kubeval .
```

If kubeval is using a default Kubernetes schema repository that is [not updated]
(https://github.com/instrumenta/kubeval/issues/301) promptly, you can use another [repo](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master):
```sh
<chart_directory>$ helm kubeval -v 1.20.0 -s \
 https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master .
```

3. install the app in the Kubernetes cluster:
```sh
<chart_directory>$ helm install <app_name> . -namespace <namespace_to_deploy_to>
```

4. check that the status of the app in the Kubernetes cluster:
```sh
helm list --namespace <namespace_where_app_deployed>
```

5. upgrade an existing deployed app:
```sh
<chart_directory>$ helm upgrade <app_name> . -namespace <namespace_to_deploy_to>
```

In the future, the charts will be hosted on a HTTP repository and Helm will
retrieve the charts from there.
