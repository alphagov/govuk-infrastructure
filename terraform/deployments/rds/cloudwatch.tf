

resource "aws_cloudwatch_dashboard" "rds" {
  dashboard_name = "govuk-${var.govuk_environment}-rds"
  dashboard_body = <<EOF

  {
      "variables": [
          {
              "type": "property",
              "property": "DBInstanceIdentifier",
              "inputType": "select",
              "id": "DBInstanceIdentifier",
              "label": "DB Instance",
              "defaultValue": "__FIRST",
              "visible": true,
              "search": "{AWS/RDS,DBInstanceIdentifier} MetricName=\"FreeStorageSpace\"",
              "populateFrom": "DBInstanceIdentifier"
          }
      ],
      "start": "-PT168H",
      "widgets": [
          {
              "type": "text",
              "x": 0,
              "y": 0,
              "width": 24,
              "height": 1,
              "properties": {
                  "markdown": "# 🗄️ RDS Storage Burn Rate & Early Warning Monitor (eu-west-1)\nDynamic thresholds based on allocated storage size. ⚠️ Warning = 25% free | 🔴 Critical = 10% free | Burn Rate = 0.2% allocated/hr | Time-to-Full: ⚠️ 48hrs 🔴 12hrs"
              }
          },
          {
              "type": "alarm",
              "x": 0,
              "y": 1,
              "width": 24,
              "height": 2,
              "properties": {
                  "title": "🚨 Storage Alarm Status",
                  "alarms": ${jsonencode(concat(values(aws_cloudwatch_metric_alarm.rds_freestoragespace)[*].arn, values(aws_cloudwatch_metric_alarm.rds_depletion_7days)[*].arn, values(aws_cloudwatch_metric_alarm.rds_depletion_48hrs)[*].arn))}
              }
          },
          {
              "type": "metric",
              "x": 0,
              "y": 3,
              "width": 4,
              "height": 3,
              "properties": {
                  "metrics": [
                      [ "AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", "$${DBInstanceIdentifier}", { "region": "eu-west-1", "color": "#2ca02c" } ]
                  ],
                  "title": "💾 Current Free Storage",
                  "view": "singleValue",
                  "region": "eu-west-1",
                  "period": 300,
                  "sparkline": true,
                  "stat": "Minimum"
              }
          },
          {
              "type": "metric",
              "x": 8,
              "y": 3,
              "width": 4,
              "height": 3,
              "properties": {
                  "metrics": [
                      [ { "expression": "IF(RATE(m1) < 0, m1 / (RATE(m1) * -3600), 9999)", "label": "Hours Remaining", "id": "e1", "region": "eu-west-1", "color": "#9467bd" } ],
                      [ "AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", "$${DBInstanceIdentifier}", { "stat": "Minimum", "period": 3600, "id": "m1", "visible": false, "region": "eu-west-1" } ]
                  ],
                  "title": "⏱️ Estimated Hours to Depletion",
                  "view": "singleValue",
                  "region": "eu-west-1",
                  "period": 300,
                  "sparkline": true,
                  "stat": "Average"
              }
          },
          {
              "type": "metric",
              "x": 4,
              "y": 3,
              "width": 4,
              "height": 3,
              "properties": {
                  "metrics": [
                      [ { "expression": "ABS(RATE(m1) * 3600)", "label": "Burn Rate (bytes/hr)", "id": "e1", "region": "eu-west-1", "color": "#d62728" } ],
                      [ "AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", "$${DBInstanceIdentifier}", { "stat": "Minimum", "period": 3600, "id": "m1", "visible": false, "region": "eu-west-1" } ]
                  ],
                  "title": "🔥 Current Burn Rate (bytes/hr)",
                  "view": "singleValue",
                  "region": "eu-west-1",
                  "period": 300,
                  "sparkline": true,
                  "stat": "Average"
              }
          },
          {
              "type": "metric",
              "x": 0,
              "y": 6,
              "width": 24,
              "height": 6,
              "properties": {
                  "metrics": [
                      [ "AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", "$${DBInstanceIdentifier}", { "id": "m1", "color": "#2ca02c", "label": "Free Storage Space (Avg)", "region": "eu-west-1" } ],
                      [ { "expression": "ANOMALY_DETECTION_BAND(m1, 2)", "label": "Expected Range (2σ)", "id": "e1", "color": "#aec7e8", "period": 3600, "region": "eu-west-1" } ]
                  ],
                  "title": "📊 Free Storage Space — Anomaly Detection Band",
                  "view": "timeSeries",
                  "stacked": false,
                  "yAxis": {
                      "left": {
                          "label": "Bytes",
                          "min": 0
                      }
                  },
                  "region": "eu-west-1",
                  "period": 3600,
                  "stat": "Average"
              }
          },
          {
              "type": "metric",
              "x": 0,
              "y": 12,
              "width": 24,
              "height": 6,
              "properties": {
                  "metrics": [
                      [ { "expression": "IF(RATE(m1) < 0, m1 / (RATE(m1) * -21600), 9999)", "label": "Hours to Depletion", "id": "e1", "color": "#9467bd", "region": "eu-west-1", "period": 21600 } ],
                      [ "AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", "$${DBInstanceIdentifier}", { "id": "m1", "visible": false, "region": "eu-west-1" } ]
                  ],
                  "title": "⏱️ Time to Depletion Trend",
                  "view": "timeSeries",
                  "stacked": false,
                  "annotations": {
                      "horizontal": [
                          {
                              "color": "#ff7f0e",
                              "label": "⚠️ Warning: < 7 days remaining",
                              "value": 168,
                              "fill": "below"
                          },
                          {
                              "color": "#d62728",
                              "label": "🚨 Critical: < 48 hrs remaining",
                              "value": 48,
                              "fill": "below"
                          }
                      ]
                  },
                  "yAxis": {
                      "left": {
                          "min": 0,
                          "max": 336,
                          "label": "Hours",
                          "showUnits": false
                      }
                  },
                  "region": "eu-west-1",
                  "period": 21600,
                  "stat": "Minimum"
              }
          },
          {
              "type": "metric",
              "x": 0,
              "y": 18,
              "width": 24,
              "height": 6,
              "properties": {
                  "metrics": [
                      [ "AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", "$${DBInstanceIdentifier}", { "id": "m1", "visible": false, "region": "eu-west-1" } ],
                      [ { "expression": "ABS(RATE(m1) * 3600)", "label": "Burn Rate (bytes/hr)", "id": "e1", "color": "#d62728", "period": 21600, "region": "eu-west-1" } ],
                      [ { "expression": "ANOMALY_DETECTION_BAND(e1, 6)", "label": "Expected Burn Rate Range (6σ)", "id": "e2", "color": "#f5b7b1", "period": 21600, "region": "eu-west-1" } ]
                  ],
                  "title": "🔥 Hourly Storage Burn Rate",
                  "view": "timeSeries",
                  "stacked": false,
                  "yAxis": {
                      "left": {
                          "label": "Bytes per Hour",
                          "min": 0
                      }
                  },
                  "region": "eu-west-1",
                  "period": 21600,
                  "stat": "Average"
              }
          },
          {
              "type": "metric",
              "x": 0,
              "y": 24,
              "width": 24,
              "height": 6,
              "properties": {
                  "metrics": [
                      [ { "expression": "RATE(ABS(RATE(m1) * 3600))", "label": "Burn Rate Acceleration (bytes/hr²)", "id": "e1", "color": "#8c564b", "region": "eu-west-1", "period": 21600 } ],
                      [ { "expression": "ANOMALY_DETECTION_BAND(e1, 4)", "label": "Expected Acceleration Range (4σ)", "id": "e2", "color": "#c49c94", "region": "eu-west-1", "period": 21600 } ],
                      [ "AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", "$${DBInstanceIdentifier}", { "stat": "Minimum", "id": "m1", "visible": false, "region": "eu-west-1" } ]
                  ],
                  "title": "📐 Burn Rate Acceleration (Rate of Change of Burn Rate)",
                  "view": "timeSeries",
                  "stacked": false,
                  "yAxis": {
                      "left": {
                          "label": "Bytes/hr²",
                          "showUnits": false
                      }
                  },
                  "region": "eu-west-1",
                  "period": 21600,
                  "stat": "Average"
              }
          },
          {
              "type": "metric",
              "x": 0,
              "y": 30,
              "width": 12,
              "height": 6,
              "properties": {
                  "metrics": [
                      [ "AWS/RDS", "TransactionLogsDiskUsage", "DBInstanceIdentifier", "$${DBInstanceIdentifier}", { "id": "m1", "color": "#e377c2", "label": "WAL Disk Usage (Max)", "region": "eu-west-1" } ],
                      [ ".", "TransactionLogsGeneration", ".", ".", { "stat": "Average", "id": "m3", "color": "#bcbd22", "label": "WAL Generation Rate (bytes/sec)", "yAxis": "right", "region": "eu-west-1" } ],
                      [ ".", "AllocatedStorage", ".", ".", { "id": "m2", "visible": false, "region": "eu-west-1" } ]
                  ],
                  "title": "📜 WAL / Transaction Log Disk Usage",
                  "view": "timeSeries",
                  "stacked": false,
                  "yAxis": {
                      "left": {
                          "label": "Bytes (Total WAL)",
                          "min": 0
                      },
                      "right": {
                          "label": "Bytes/sec (Generation Rate)",
                          "min": 0
                      }
                  },
                  "region": "eu-west-1",
                  "period": 300,
                  "stat": "Maximum"
              }
          },
          {
              "type": "metric",
              "x": 12,
              "y": 30,
              "width": 12,
              "height": 6,
              "properties": {
                  "metrics": [
                      [ "AWS/RDS", "ReplicationSlotDiskUsage", "DBInstanceIdentifier", "$${DBInstanceIdentifier}", { "id": "m1", "color": "#8c564b", "label": "Replication Slot Disk Usage (Max)", "region": "eu-west-1" } ],
                      [ ".", "OldestReplicationSlotLag", ".", ".", { "id": "m3", "color": "#17becf", "label": "Oldest Replication Slot Lag", "yAxis": "right", "region": "eu-west-1" } ]
                  ],
                  "title": "🔗 Replication Slot Disk Usage & Lag",
                  "view": "timeSeries",
                  "stacked": false,
                  "yAxis": {
                      "left": {
                          "label": "Bytes (Slot Disk Usage)",
                          "min": 0
                      },
                      "right": {
                          "label": "Bytes (Slot Lag)",
                          "min": 0
                      }
                  },
                  "region": "eu-west-1",
                  "period": 300,
                  "stat": "Maximum"
              }
          },
          {
              "type": "metric",
              "x": 0,
              "y": 36,
              "width": 12,
              "height": 6,
              "properties": {
                  "title": "✍️ Write Activity (IOPS & Throughput)",
                  "view": "timeSeries",
                  "stacked": false,
                  "metrics": [
                      [ "AWS/RDS", "WriteIOPS", "DBInstanceIdentifier", "$${DBInstanceIdentifier}", { "stat": "Average", "period": 300, "color": "#1f77b4", "label": "Write IOPS" } ],
                      [ "AWS/RDS", "WriteThroughput", "DBInstanceIdentifier", "$${DBInstanceIdentifier}", { "stat": "Average", "period": 300, "color": "#ff7f0e", "label": "Write Throughput (bytes/sec)", "yAxis": "right" } ]
                  ],
                  "yAxis": {
                      "left": {
                          "label": "IOPS",
                          "min": 0
                      },
                      "right": {
                          "label": "Bytes/sec",
                          "min": 0
                      }
                  },
                  "region": "eu-west-1",
                  "period": 300
              }
          },
          {
              "type": "metric",
              "x": 12,
              "y": 36,
              "width": 12,
              "height": 6,
              "properties": {
                  "title": "🔄 Database Connections & Max Used Transaction IDs",
                  "view": "timeSeries",
                  "stacked": false,
                  "metrics": [
                      [ "AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "$${DBInstanceIdentifier}", { "stat": "Average", "period": 300, "color": "#2ca02c", "label": "Database Connections" } ],
                      [ "AWS/RDS", "MaximumUsedTransactionIDs", "DBInstanceIdentifier", "$${DBInstanceIdentifier}", { "stat": "Maximum", "period": 300, "color": "#d62728", "label": "Max Used Transaction IDs", "yAxis": "right" } ]
                  ],
                  "yAxis": {
                      "left": {
                          "label": "Connections",
                          "min": 0
                      },
                      "right": {
                          "label": "Transaction IDs",
                          "min": 0
                      }
                  },
                  "region": "eu-west-1",
                  "period": 300
              }
          }
      ]
  }

EOF
}

resource "aws_cloudwatch_metric_alarm" "rds_depletion_7days" {
  for_each = var.databases

  alarm_name        = "${aws_db_instance.instance[each.key].identifier}-rds-depletion_7_days"
  alarm_description = "Triggers when ${aws_db_instance.instance[each.key].identifier} is predicted to run out of storage in the next 7 days."

  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  threshold           = 168 # 7 days (in hours)
  alarm_actions       = [aws_sns_topic.rds_alerts.arn]
  ok_actions          = [aws_sns_topic.rds_alerts.arn]

  metric_query {
    id          = "e1"
    label       = "Hours to Depletion"
    expression  = "IF(RATE(m1) < 0, m1 / (RATE(m1) * -21600), 9999)"
    return_data = true
  }

  metric_query {
    id = "m1"

    metric {
      namespace   = "AWS/RDS"
      metric_name = "FreeStorageSpace"
      period      = 21600 # 6-hour interval
      stat        = "Minimum"

      dimensions = {
        DBInstanceIdentifier = aws_db_instance.instance[each.key].identifier
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_depletion_48hrs" {
  for_each = var.databases

  alarm_name        = "${aws_db_instance.instance[each.key].identifier}-rds-depletion-48hrs"
  alarm_description = "Triggers when ${aws_db_instance.instance[each.key].identifier} is predicted to run out of storage in the next 48 hours."

  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  threshold           = 48
  alarm_actions       = [aws_sns_topic.rds_alerts.arn]
  ok_actions          = [aws_sns_topic.rds_alerts.arn]

  metric_query {
    id          = "e1"
    label       = "Hours to Depletion"
    expression  = "IF(RATE(m1) < 0, m1 / (RATE(m1) * -21600), 9999)"
    return_data = true
  }

  metric_query {
    id = "m1"

    metric {
      namespace   = "AWS/RDS"
      metric_name = "FreeStorageSpace"
      period      = 21600 # 6-hour interval
      stat        = "Minimum"

      dimensions = {
        DBInstanceIdentifier = aws_db_instance.instance[each.key].identifier
      }
    }
  }
}
