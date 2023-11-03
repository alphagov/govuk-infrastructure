alertmanager:
  config:
    global:
      resolve_timeout: 5m
      slack_api_url: ${slack_api_url}
    route:
      receiver: 'null'
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 4h
      group_by: [alertname, namespace]
      routes:
      - match:
          severity: page
        receiver: 'pagerduty'
      - match:
          alertname: Watchdog
        receiver: 'pagerduty'
        active_time_intervals:
        - pagerduty_drill
      - match:
          alertname: SignonApiUserTokenExpirySoon
        receiver: 'slack-signon-token-expiry'
        repeat_interval: 1d
        group_wait: 12h
        group_interval: 12h
        active_time_intervals:
        - inhours
      - match:
          alertname: MirrorFreshnessAlert
        receiver: 'slack-mirror-freshness'
        repeat_interval: 1d
        group_wait: 12h
        group_interval: 12h
        active_time_intervals:
        - inhours
    receivers:
    - name: 'null'
    - name: 'pagerduty'
      pagerduty_configs:
      - routing_key: ${routing_key}
        client_url: "https://${alertmanager_host}/#/alerts?receiver={{ .Receiver | urlquery }}"
    - name: 'slack-signon-token-expiry'
      slack_configs:
      - channel: '#govuk-2ndline-tech'
        send_resolved: true
        icon_url: https://avatars3.githubusercontent.com/u/3380462
        title: |-
         {{ if eq .CommonLabels.alertname "Watchdog" }}CRITICAL: 'PagerDuty test drill. Developers: escalate this alert. SMT: resolve this alert.'{{ end }}
         {{ if not eq .CommonLabels.alertname "Watchdog" }}[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .CommonLabels.alertname }}{{ end }}
        text: >-
         *Description:* {{ .CommonAnnotations.description }}

         *Environment:* ${environment}

         *Runbook:* {{ .CommonAnnotations.runbook_url }}

         *Expiring tokens:*

         {{ range .Alerts -}}
           • api_user: `{{ .Labels.api_user }}`, application: `{{ .Labels.application }}`
         {{ end }}
    - name: 'slack-mirror-freshness'
      slack_configs:
      - channel: '#govuk-platform-engineering'
        send_resolved: true
        icon_url: https://avatars3.githubusercontent.com/u/3380462
        title: |-
         [{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .CommonLabels.alertname }}
        text: >-
         *Description:* {{ .CommonAnnotations.description }}

         *Environment:* ${environment}

         *Mirror*: {{ $labels.backend }}
    time_intervals:
    - name: inhours
      time_intervals:
      - weekdays: ['monday:friday']
    - name: pagerduty_drill
      time_intervals:
      - weekdays: ['wednesday']
        times: 
        - start_time: 10:00
          end_time: 10:03
        location: 'Europe/London'
