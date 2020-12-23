locals {
  system_metrics_dashboard_config = {
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
    "editable" : true,
    "gnetId" : null,
    "graphTooltip" : 0,
    "links" : [],
    "panels" : [
      {
        "aliasColors" : {},
        "bars" : false,
        "dashLength" : 10,
        "dashes" : false,
        "datasource" : "cloudwatch",
        "fieldConfig" : {
          "defaults" : {
            "custom" : {}
          },
          "overrides" : []
        },
        "fill" : 1,
        "fillGradient" : 0,
        "gridPos" : {
          "h" : 8,
          "w" : 12,
          "x" : 0,
          "y" : 0
        },
        "hiddenSeries" : false,
        "id" : 2,
        "legend" : {
          "avg" : false,
          "current" : false,
          "max" : false,
          "min" : false,
          "show" : true,
          "total" : false,
          "values" : false
        },
        "lines" : true,
        "linewidth" : 1,
        "nullPointMode" : "null",
        "options" : {
          "alertThreshold" : true
        },
        "percentage" : false,
        "pluginVersion" : "7.3.4",
        "pointradius" : 2,
        "points" : false,
        "renderer" : "flot",
        "seriesOverrides" : [],
        "spaceLength" : 10,
        "stack" : false,
        "steppedLine" : false,
        "targets" : [
          {
            "alias" : "",
            "dimensions" : {
              "ClusterName" : "govuk",
              "ServiceName" : "*"
            },
            "expression" : "",
            "id" : "",
            "matchExact" : true,
            "metricName" : "CPUUtilization",
            "namespace" : "AWS/ECS",
            "period" : "",
            "queryType" : "randomWalk",
            "refId" : "A",
            "region" : "default",
            "statistics" : [
              "Average"
            ]
          }
        ],
        "thresholds" : [],
        "timeFrom" : null,
        "timeRegions" : [],
        "timeShift" : null,
        "title" : "CPU Utilization by App",
        "tooltip" : {
          "shared" : true,
          "sort" : 0,
          "value_type" : "individual"
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
            "format" : "short",
            "label" : null,
            "logBase" : 1,
            "max" : "100",
            "min" : null,
            "show" : true
          },
          {
            "format" : "short",
            "label" : null,
            "logBase" : 1,
            "max" : null,
            "min" : null,
            "show" : true
          }
        ],
        "yaxis" : {
          "align" : false,
          "alignLevel" : null
        }
      },
      {
        "aliasColors" : {},
        "bars" : false,
        "dashLength" : 10,
        "dashes" : false,
        "datasource" : "cloudwatch",
        "fieldConfig" : {
          "defaults" : {
            "custom" : {}
          },
          "overrides" : []
        },
        "fill" : 1,
        "fillGradient" : 0,
        "gridPos" : {
          "h" : 8,
          "w" : 12,
          "x" : 12,
          "y" : 0
        },
        "hiddenSeries" : false,
        "id" : 4,
        "legend" : {
          "avg" : false,
          "current" : false,
          "max" : false,
          "min" : false,
          "show" : true,
          "total" : false,
          "values" : false
        },
        "lines" : true,
        "linewidth" : 1,
        "nullPointMode" : "null",
        "options" : {
          "alertThreshold" : true
        },
        "percentage" : false,
        "pluginVersion" : "7.3.4",
        "pointradius" : 2,
        "points" : false,
        "renderer" : "flot",
        "seriesOverrides" : [],
        "spaceLength" : 10,
        "stack" : false,
        "steppedLine" : false,
        "targets" : [
          {
            "alias" : "",
            "dimensions" : {
              "ClusterName" : "govuk",
              "ServiceName" : "*"
            },
            "expression" : "",
            "id" : "",
            "matchExact" : true,
            "metricName" : "MemoryUtilized",
            "namespace" : "ECS/ContainerInsights",
            "period" : "",
            "queryType" : "randomWalk",
            "refId" : "A",
            "region" : "default",
            "statistics" : [
              "Average"
            ]
          }
        ],
        "thresholds" : [],
        "timeFrom" : null,
        "timeRegions" : [],
        "timeShift" : null,
        "title" : "Memory Utilization by App",
        "tooltip" : {
          "shared" : true,
          "sort" : 0,
          "value_type" : "individual"
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
            "format" : "short",
            "label" : null,
            "logBase" : 1,
            "max" : null,
            "min" : null,
            "show" : true
          },
          {
            "format" : "short",
            "label" : null,
            "logBase" : 1,
            "max" : null,
            "min" : null,
            "show" : true
          }
        ],
        "yaxis" : {
          "align" : false,
          "alignLevel" : null
        }
      },
      {
        "aliasColors" : {},
        "bars" : false,
        "dashLength" : 10,
        "dashes" : false,
        "datasource" : "cloudwatch",
        "fieldConfig" : {
          "defaults" : {
            "custom" : {}
          },
          "overrides" : []
        },
        "fill" : 0,
        "fillGradient" : 0,
        "gridPos" : {
          "h" : 8,
          "w" : 12,
          "x" : 0,
          "y" : 8
        },
        "hiddenSeries" : false,
        "id" : 6,
        "legend" : {
          "avg" : false,
          "current" : false,
          "max" : false,
          "min" : false,
          "show" : true,
          "total" : false,
          "values" : false
        },
        "lines" : true,
        "linewidth" : 1,
        "nullPointMode" : "null",
        "options" : {
          "alertThreshold" : true
        },
        "percentage" : false,
        "pluginVersion" : "7.3.4",
        "pointradius" : 2,
        "points" : false,
        "renderer" : "flot",
        "seriesOverrides" : [],
        "spaceLength" : 10,
        "stack" : false,
        "steppedLine" : false,
        "targets" : [
          {
            "alias" : "",
            "dimensions" : {
              "ClusterName" : "govuk",
              "ServiceName" : "*"
            },
            "expression" : "",
            "id" : "",
            "matchExact" : true,
            "metricName" : "RunningTaskCount",
            "namespace" : "ECS/ContainerInsights",
            "period" : "",
            "queryType" : "randomWalk",
            "refId" : "A",
            "region" : "default",
            "statistics" : [
              "Average"
            ]
          }
        ],
        "thresholds" : [],
        "timeFrom" : null,
        "timeRegions" : [],
        "timeShift" : null,
        "title" : "Running Task Count by App",
        "tooltip" : {
          "shared" : true,
          "sort" : 0,
          "value_type" : "individual"
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
            "format" : "short",
            "label" : null,
            "logBase" : 1,
            "max" : null,
            "min" : null,
            "show" : true
          },
          {
            "format" : "short",
            "label" : null,
            "logBase" : 1,
            "max" : null,
            "min" : null,
            "show" : true
          }
        ],
        "yaxis" : {
          "align" : false,
          "alignLevel" : null
        }
      },
      {
        "aliasColors" : {},
        "bars" : false,
        "dashLength" : 10,
        "dashes" : false,
        "datasource" : "cloudwatch",
        "fieldConfig" : {
          "defaults" : {
            "custom" : {}
          },
          "overrides" : []
        },
        "fill" : 1,
        "fillGradient" : 0,
        "gridPos" : {
          "h" : 8,
          "w" : 12,
          "x" : 12,
          "y" : 8
        },
        "hiddenSeries" : false,
        "id" : 8,
        "legend" : {
          "avg" : false,
          "current" : false,
          "max" : false,
          "min" : false,
          "show" : true,
          "total" : false,
          "values" : false
        },
        "lines" : true,
        "linewidth" : 1,
        "nullPointMode" : "null",
        "options" : {
          "alertThreshold" : true
        },
        "percentage" : false,
        "pluginVersion" : "7.3.4",
        "pointradius" : 2,
        "points" : false,
        "renderer" : "flot",
        "seriesOverrides" : [],
        "spaceLength" : 10,
        "stack" : false,
        "steppedLine" : false,
        "targets" : [
          {
            "alias" : "",
            "dimensions" : {
              "ClusterName" : "govuk",
              "ServiceName" : "*"
            },
            "expression" : "",
            "id" : "",
            "matchExact" : true,
            "metricName" : "NetworkRxBytes",
            "namespace" : "ECS/ContainerInsights",
            "period" : "",
            "queryType" : "randomWalk",
            "refId" : "A",
            "region" : "default",
            "statistics" : [
              "Average"
            ]
          }
        ],
        "thresholds" : [],
        "timeFrom" : null,
        "timeRegions" : [],
        "timeShift" : null,
        "title" : "NetworkRx by App",
        "tooltip" : {
          "shared" : true,
          "sort" : 0,
          "value_type" : "individual"
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
            "format" : "short",
            "label" : null,
            "logBase" : 1,
            "max" : null,
            "min" : null,
            "show" : true
          },
          {
            "format" : "short",
            "label" : null,
            "logBase" : 1,
            "max" : null,
            "min" : null,
            "show" : true
          }
        ],
        "yaxis" : {
          "align" : false,
          "alignLevel" : null
        }
      }
    ],
    "schemaVersion" : 26,
    "style" : "dark",
    "tags" : [],
    "templating" : {
      "list" : []
    },
    "time" : {
      "from" : "now-6h",
      "to" : "now"
    },
    "timepicker" : {},
    "timezone" : "",
    "title" : "System Metrics",
    "uid" : "P4LjXx0Mk"
  }
}

resource "grafana_dashboard" "system_metrics" {
  folder      = grafana_folder.govuk_publishing_platform.id
  config_json = jsonencode(local.system_metrics_dashboard_config)

  depends_on = [grafana_data_source.cloudwatch]
}
