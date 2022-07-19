alertmanager:
  config:
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
    receivers:
    - name: 'null'
    - name: 'pagerduty'
      pagerduty_configs:
      - routing_key: ${routing_key}
        client_url: "https://${alertmanager_host}/#/alerts?receiver={{ .Receiver | urlquery }}"
