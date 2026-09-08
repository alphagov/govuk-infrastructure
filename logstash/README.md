# Logstash configuration

`logstash.conf` contains the Logstash filters used for integration, staging and production in Logit.

## How to use

Before applying the Logstash configuration test that it is valid:

1. Navigate to the Logit dashboard
2. Select `Settings` in the desired environment (e.g. `GOV.UK Integration EKS`)
3. Select `Logstash Pipelines`
4. Copy `logstash.conf` into the Logstash Pipeline Editor
5. Press `Test Configuration`

If this is valid then raise a PR. Then select `Apply Changes`. Inspect the logs after a few minutes have passed to verify the configuration has applied properly.

### Elastic Common Schema (ECS) fields

Filebeat uses some of the [ECS fields](https://www.elastic.co/docs/reference/beats/filebeat/exported-fields-ecs) when emitting to Logstash. Here the `message` field that exported by Filebeat is accessed by the Logstash filter:

```
if [message] =~ /^{.*}/ {
    json {
      source => "message"
      target => "logjson"
      skip_on_invalid_json => true
    }
    ...
}
```

The best way to verify what ECS fields Filebeat exports is to look at the raw JSON in Kibana. Here we have `@timestamp`, `tags` and `message`:

```
{
  "_index": "filebeat-2026.09.08",
  ...
  "_source": {
    "@timestamp": "2026-09-08T13:47:53.626Z",
    "tags": [
      "beats_input_codec_plain_applied"
    ],
    "message": "...",
}
```

### Kubernetes fields

Kubernetes fields (e.g. `kubernetes.container.name`) are added by Filebeat through the [Kubernetes processor](https://www.elastic.co/docs/reference/beats/filebeat/exported-fields-kubernetes-processor) in [Filebeat](https://github.com/alphagov/govuk-infrastructure/blob/b83e8f06a43d1e56854b61d6c6e61d8dc964b51e/terraform/deployments/cluster-services/filebeat.yml#L17)

### Logstash Filters

Most of our logs are in JSON format so the [json filter](https://www.elastic.co/docs/reference/logstash/plugins/plugins-filters-json) will extract and place it into a `logjson` field. The [useragent filter](https://www.elastic.co/docs/reference/logstash/plugins/plugins-filters-useragent) can extract these from `logjson.http_user_agent` and place it at root. Useragent headers are found in both nginx and Ruby apps:

1. nginx:

```
{
	"@timestamp": "2026-08-27T14:52:01+00:00",
	"body_bytes_sent": 70911,
	"bytes_sent": 74501,
	"govuk_request_id": "xxxx-xxxx-xxxx-xxxx-xxxx",
	"http_host": "frontend",
	"http_referer": "",
	"http_user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko; GraphConnectors) Chrome/76.0.3809.132 Safari/537.36",
	"status": 200,
	"upstream_response_time": "0.031",
    ...
}
```

2. Ruby apps:

```
{
    "@timestamp": "2026-08-27T13:31:11+00:00",
    "body_bytes_sent": 15768,
    "bytes_sent": 16400,
    "govuk_request_id": "xxxx-xxxx-xxxx-xxxx-xxxx",
    "http_host": "content-store",
    "http_referer": "",
    "http_user_agent": "gds-api-adapters/103.4.2 (frontend)",
    "status": 200,
    "upstream_response_time": "0.005",
    ...
}
```

Some logs contain a `message` field which will be transformed to `logjson_message` (e.g. mirror) at root:

```json
{
  "level": "error",
  "error": "failed to write object: operation error S3: PutObject, https response error StatusCode: 400, RequestID: 1AKSBKC3WKF9V32X, HostID: iM7JWoNA/wwz1uzaoSujKa1YVavVTMYMYc4qs9VveJq89+moep6xa7XKSHQsJ8irTfYnATAmf5xd8wG1tnxGvaZbDQFwGMZ5, api error BadDigest: The SHA1 you specified did not match the calculated checksum.",
  "time": 1788862294,
  "message": "Error uploading www.gov.uk/employment-tribunal-decisions.html"
}
```

Some Sidekiq logs have nested objects (e.g. `logjson_message.queues`) so these are extracted out to `logjson_sidekiq_object.*` at root:

```
{
    "@timestamp": "2026-09-02T15:56:53.009Z",
    "pid": 1,
    "tid": "2l5",
    "level": "DEBUG",
    "message": {
        ...,
        "lifecycle_events": {
            "startup": [],
            "quiet": [
                "#<Proc:0x0000ffff6dbed850 /usr/local/bundle/ruby/4.0/gems/sidekiq-8.1.6/lib/active_job/queue_adapters/sidekiq_adapter.rb:50 (lambda)>"
            ],
            ...
        },
        "dead_max_jobs": 10000,
        "dead_timeout_in_seconds": 15552000,
        "queues": [
            "default",
            "mailers",
            "logstream"
        ],
        "config_file": "config/sidekiq.yml",
        "tag": "app",
        "identity": "signon-worker-xxxx"
    },
    "tags": [
        "sidekiq"
    ]
},
{
    ...
    "on_complex_arguments": "raise",
    "average_scheduled_poll_interval": 5,
    "dead_timeout_in_seconds": 15552000,
    "identity": "signon-worker-xxxx"
    "queues": [
        "default",
        "mailers",
        "logstream"
    ],
    "redis_idle_timeout": null,
    "tag": "app",
    "dead_max_jobs": 10000,
    "config_file": "config/sidekiq.yml"
}
```