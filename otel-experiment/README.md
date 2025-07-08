# Open Telemetry send k8sevents experiment

This directory was the result of an experiment to use opentelemtry with the k8sevents receiver to send the events to logit. For this experiment instead of sending to logit we run an ELK stack in a kubernetes cluster of your choosing.

It gets us very close to a possible integration test without having to send to logit (so very useful on a PR), we would just need to:

1. `kubectl wait...` for the elasticsearch pod to be healthy, 
2. Deploy something (I've been deleting and applying the logstash deployment since it isn't useful and is broken anyway) to generate some k8s events
3. Query elasticsearch to ensure they have been received and transformed correctly

Although there is a full ELK stack, the Logstash component isn't used, opentelemetry has an elasticsearch and an opensearch exporter, but not logstash exporter. Logstash also doesn't have the credentials it needs to write to elasticsearch, so once elasticsearch is available, logstash will go into a crash loop.

Currently all of the GOV.UK logs from inside EKS are sent to logstash, so we are putting this experiment on hold while we map out exactly how out log pipelines work, and then we can decide if we can send directly to elasticsearch.

## How to

### Prerequisites

* A kubernetes cluster you can apply to, and a context set up for it with kubectl
* pwgen (On macOS you can `brew install pwgen` to get this)

### Setup

NOTE: By default this setup uses a kubernetes cluster with traefik as the traffic router, and configures it to listen for hostname `kibana.k8s.eviljonnys.com. You probably need to adjust these, but you can do so in `manifests/34-kibana-ingress.yaml`

You can start everything by running the create script in this folder:

```
./create.sh &lt;kubectl context>
```

This will:

1. Create secrets in a subfolder called `secrets` (which is purposefully git ignored), they will be generated with pwgen, and then kubernetes manifests made for them (also in `secrets/`)
2. Apply all the manifests in the manifests subfolder (note: this will make a new namespace called elk, and everything except for the required ClusterRole and ClusterRoleBinding will be created in this namespace)

The most important secret for you is the secret in `secrets/elasticsearch/ELASTIC_PASSWORD` as this will allow you log into the kibana UI.


### Logging in to Kibana

You can log into kibana with the username `elastic` and the password which has been saved into `secrets/elasticsearch/ELASTIC_PASSWORD`.

### Tear down

To tear everything down you can run the delete script in this folder:

```
./delete.sh &lt;kubectl context>
```

## Bibliography

* [Logit guide to configuring Open Telemtry to send to Logit](https://logit.io/docs/integrations/otel-collector/)
* Open Telemetry modules
    * [k8sevents receiver](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/k8seventsreceiver)
    * [ElasticSearch exporter](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/elasticsearchexporter)
    * [OpenSearch exporter](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/opensearchexporter)
