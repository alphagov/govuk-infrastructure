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

Other Sidekiq logs (e.g. publishing-api's `Unlocked` messages) also put an object in `message`, but without `queues`:

```
{
    "@timestamp": "2026-11-19T17:04:41.602Z",
    "pid": 1,
    "tid": "xxx",
    "level": "INFO",
    "message": {
        "message": "Unlocked",
        "args": [
            {
                "content_id": "xxxx-xxxx-xxxx-xxxx-xxxx",
                "locale": "en",
                "update_dependencies": true,
                "orphaned_content_ids": [],
                "source_command": "put_content",
                "source_fields": ["public_updated_at"]
            }
        ],
        "jid": "xxxx",
        "lock_args": ["xxxx-xxxx-xxxx-xxxx-xxxx", "en", true, [], "DownstreamDraftJob"],
        "queue": "downstream_high",
        ...
    }
}
```

`logjson_message` is mapped as a `keyword`, so OpenSearch rejects these objects (`failed to parse field [logjson_message] of type [keyword]`) and they land in the dead letter queue. When `logjson_message` has a `message` or `jid` key, the job object is moved to `[@metadata]`, which is never indexed, and only its inner `message` string (e.g. `Unlocked`) is kept in `logjson_message`, as with other Sidekiq logs. The full job is still searchable in the raw top-level `message` field.

The job object isn't moved into `logjson_sidekiq_object`, because fields such as `lock_args` mix strings, booleans and arrays, which would cause new mapping conflicts there. Logit doesn't allow the `ruby` filter, so the object can't be converted to a JSON string either.

### Fields with conflicting types

OpenSearch sets the type of each field in a daily index (e.g. `filebeat-2026.11.19`) from the first document of the day that contains it. All apps share the `logjson` object, so when two apps send the same field with different types, the later type is rejected for the rest of the day and those logs go to the dead letter queue. Which apps lose logs can change from day to day, depending on which one logs first after midnight.

These fields are renamed to a `_text` field when they aren't numeric, so the original field always stays numeric:

| Field | Numeric value (kept) | Non-numeric value (renamed) | Renamed to |
|---|---|---|---|
| `logjson.status` | `200` (nginx, Ruby apps) | a non-numeric string (email-alert-frontend) | `logjson.status_text` |
| `logjson.ts` | `1795108151.7868207` (zap apps, e.g. gatekeeper) | `"2026-11-19T17:07:57Z"` (controller-runtime apps, e.g. aws-load-balancer-controller) | `logjson.ts_text` |
| `logjson.duration` | `0.031` | `"1.518508839s"` (Go durations, e.g. gatekeeper) | `logjson.duration_text` |

For example, aws-load-balancer-controller logs:

```json
{"level":"info","ts":"2026-11-19T17:07:57Z","msg":"Skipping targetgroupbinding reconcile","tgb":{"name":"k8s-apps-xxxx","namespace":"apps"}}
```

whereas gatekeeper logs:

```json
{"level":"info","ts":1795108151.7868207,"logger":"controller","msg":"auditing is complete","process":"audit","event_type":"audit_finished","duration":"1.518508839s"}
```

The numeric check for `ts` and `duration` also allows `e`, `E` and `+`, so epoch values that Logstash writes in exponent form (e.g. `0.17951081517868207e10`) aren't renamed.

Some fields are an object in some logs and a string in others. OpenSearch rejects the second form with `object mapping for [logjson.<field>] tried to parse field [<field>] as object, but found a concrete value` (or `failed to parse field [logjson.<field>] of type [keyword]` if a string came first that day). For these, the object is kept and strings are renamed to a `_text` field:

| Field | Object value (kept) | String value (renamed) | Renamed to |
|---|---|---|---|
| `logjson.source` | `{"function": "...", "file": "...", "line": 42}` (e.g. Go `slog` with source locations) | `"auth-service"` (eks-pod-identity-agent) | `logjson.source_text` |
| `logjson.tgb` | `{"name": "k8s-apps-xxxx", "namespace": "apps"}` (aws-load-balancer-controller) | `"k8s-apps-xxxx"` (aws-load-balancer-controller, e.g. `enqueued new deferred TGB`) | `logjson.tgb_text` |

These rules use `=~ /.*/` to detect strings. Logstash regex conditionals [only match string values](https://github.com/elastic/logstash/blob/main/logstash-core/src/main/java/org/logstash/config/ir/compiler/EventCondition.java) and are false for objects and numbers, so objects are never renamed, even when their keys aren't known.

### Investigating the dead letter queue

Rejected events are written to the `dlq-YYYY.MM.DD` index. The `dead_letter_queue_reason` field contains the OpenSearch error, which names the field and its mapped type, for example:

```
failed to parse field [logjson.ts] of type [float] in document with id '...'. Preview of field's value: '2026-11-19T17:07:57Z'
```

Group the entries by field and by source (`kubernetes.namespace` and container) to find the apps involved, then add a rule like the ones above. A fix only takes effect from the next daily index, because an existing index keeps its mappings.

Logs that Fluent Bit ships directly to OpenSearch (e.g. `kubernetes-events-*` from kubernetes-events-shipper) don't go through Logstash, so their rejections don't appear in the dead letter queue. Check the shipper's own logs for those.
