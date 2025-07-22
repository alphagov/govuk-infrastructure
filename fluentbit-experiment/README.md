# Fluent Bit send k8sevents experiment

This directory was the result of an experiment to use Fluent Bit with the kubernetes_events input to send the events to logit. For this experiment instead of sending to logit we run an ElasticSearch "cluster" in a kubernetes cluster of your choosing.

## How to

### Prerequisites

* A kubernetes cluster you can apply to, and a context set up for it with kubectl
* pwgen (On macOS you can `brew install pwgen` to get this)
* GNU Date (default on linux distros, can be installed with `brew install coreutils` on macOS)

### Setup

You can start everything by running the create script in this folder:

```
./create.sh &lt;kubectl context>
```

This will:

1. Create secrets in a subfolder called `secrets` (which is purposefully git ignored), they will be generated with pwgen, and then kubernetes manifests made for them (also in `secrets/`)
2. Apply all the manifests in the manifests subfolder (note: this will make a new namespace called elk, and everything except for the required ClusterRole and ClusterRoleBinding will be created in this namespace)

You can execute API queries against elasticsearch like so:

```
kubectl exec deployments/elasticsearch -- \
  bash -c \
    'curl "elastic:${ELASTIC_PASSWORD}" http://127.0.0.1:9200/k8s-events/_search?pretty' -d '{ "query": { "query_string": { "query": "nginx-dummy" } }'
```

### Execute the Tests

The tests will:

1. apply the manifest 99-nginx-dummy.yaml repeatedly to ensure there are plenty of events
2. Query ElasticSeach to find some of those events
3. Compare values in those events against the expected values

```
./test.sh &lt;kubectl context>
```

### Tear down

To tear everything down you can run the delete script in this folder:

```
./delete.sh &lt;kubectl context>
```

## Bibliography

* [Fluent Bit kubernetes_events input](https://docs.fluentbit.io/manual/pipeline/inputs/kubernetes-events)
* [Fluent Bit ElasticSearch output](https://docs.fluentbit.io/manual/pipeline/outputs/elasticsearch)
* [Fluent Bit opensearch output](https://docs.fluentbit.io/manual/pipeline/outputs/opensearch)
