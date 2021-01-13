locals {
  billing_dashboard_config = {
    "annotations" : {
      "list" : [
        {
          "builtIn" : 1,
          "datasource" : "-- Grafana --",
          "enable" : true,
          "hide" : true,
          "iconColor" : "rgba(0, 211, 255, 1)",
          "name" : "Annotations & Alerts",
          "type" : "dashboard"
        }
      ]
    },
    "description" : "Estimated AWS charges per AWS resource",
    "editable" : true,
    "gnetId" : 139,
    "graphTooltip" : 0,
    "iteration" : 1607515604049,
    "links" : [],
    "panels" : [
      {
        "aliasColors" : {},
        "bars" : false,
        "dashLength" : 10,
        "dashes" : false,
        "datasource" : "cloudwatch",
        "editable" : true,
        "error" : false,
        "fieldConfig" : {
          "defaults" : {
            "custom" : {},
            "links" : []
          },
          "overrides" : []
        },
        "fill" : 1,
        "fillGradient" : 0,
        "grid" : {},
        "gridPos" : {
          "h" : 15,
          "w" : 24,
          "x" : 0,
          "y" : 0
        },
        "hiddenSeries" : false,
        "id" : 1,
        "isNew" : true,
        "legend" : {
          "alignAsTable" : true,
          "avg" : true,
          "current" : true,
          "hideEmpty" : false,
          "hideZero" : false,
          "max" : true,
          "min" : true,
          "show" : true,
          "sort" : "current",
          "sortDesc" : true,
          "total" : false,
          "values" : true
        },
        "lines" : true,
        "linewidth" : 2,
        "links" : [],
        "nullPointMode" : "connected",
        "options" : {
          "alertThreshold" : true
        },
        "percentage" : false,
        "pluginVersion" : "7.3.4",
        "pointradius" : 5,
        "points" : false,
        "renderer" : "flot",
        "seriesOverrides" : [],
        "spaceLength" : 10,
        "stack" : false,
        "steppedLine" : false,
        "targets" : [
          {
            "alias" : "Total",
            "application" : {
              "filter" : ""
            },
            "dimensions" : {
              "Currency" : "USD"
            },
            "expression" : "",
            "functions" : [],
            "group" : {
              "filter" : ""
            },
            "highResolution" : false,
            "host" : {
              "filter" : ""
            },
            "id" : "",
            "item" : {
              "filter" : ""
            },
            "matchExact" : true,
            "metricName" : "EstimatedCharges",
            "mode" : 0,
            "namespace" : "AWS/Billing",
            "options" : {
              "showDisabledItems" : false
            },
            "period" : "",
            "refId" : "A",
            "region" : "us-east-1",
            "returnData" : false,
            "statistics" : [
              "Average"
            ]
          },
          {
            "alias" : "{{ServiceName}}",
            "application" : {
              "filter" : ""
            },
            "dimensions" : {
              "Currency" : "USD",
              "ServiceName" : "*"
            },
            "expression" : "",
            "functions" : [],
            "group" : {
              "filter" : ""
            },
            "highResolution" : false,
            "host" : {
              "filter" : ""
            },
            "id" : "",
            "item" : {
              "filter" : ""
            },
            "matchExact" : true,
            "metricName" : "EstimatedCharges",
            "mode" : 0,
            "namespace" : "AWS/Billing",
            "options" : {
              "showDisabledItems" : false
            },
            "period" : "",
            "refId" : "B",
            "region" : "us-east-1",
            "returnData" : false,
            "statistics" : [
              "Average"
            ]
          }
        ],
        "thresholds" : [],
        "timeFrom" : null,
        "timeRegions" : [],
        "timeShift" : null,
        "title" : "Estimated charges",
        "tooltip" : {
          "msResolution" : false,
          "shared" : true,
          "sort" : 2,
          "value_type" : "cumulative"
        },
        "type" : "graph",
        "xaxis" : {
          "buckets" : null,
          "mode" : "time",
          "name" : null,
          "show" : true,
          "values" : []
        },
        "yaxes" : [
          {
            "format" : "currencyUSD",
            "label" : null,
            "logBase" : 1,
            "max" : null,
            "min" : 0,
            "show" : true
          },
          {
            "format" : "short",
            "label" : null,
            "logBase" : 1,
            "max" : null,
            "min" : null,
            "show" : false
          }
        ],
        "yaxis" : {
          "align" : false,
          "alignLevel" : null
        }
      }
    ],
    "refresh" : false,
    "schemaVersion" : 26,
    "style" : "dark",
    "tags" : [],
    "templating" : {
      "list" : [
        {
          "current" : {
            "selected" : false,
            "text" : "cloudwatch",
            "value" : "cloudwatch"
          },
          "error" : null,
          "hide" : 0,
          "includeAll" : false,
          "label" : "Datasource",
          "multi" : false,
          "name" : "datasource",
          "options" : [],
          "query" : "cloudwatch",
          "refresh" : 1,
          "regex" : "",
          "skipUrlSync" : false,
          "type" : "datasource"
        }
      ]
    },
    "time" : {
      "from" : "now-30d",
      "to" : "now"
    },
    "timepicker" : {
      "refresh_intervals" : [
        "5s",
        "10s",
        "30s",
        "1m",
        "5m",
        "15m",
        "30m",
        "1h",
        "2h",
        "1d"
      ],
      "time_options" : [
        "5m",
        "15m",
        "1h",
        "6h",
        "12h",
        "24h",
        "2d",
        "7d",
        "30d"
      ]
    },
    "timezone" : "browser",
    "title" : "AWS Billing"
  }
}

resource "grafana_dashboard" "billing" {
  folder      = grafana_folder.govuk_publishing_platform.id
  config_json = jsonencode(local.billing_dashboard_config)

  depends_on = [grafana_data_source.cloudwatch]
}
