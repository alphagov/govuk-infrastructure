resource "helm_release" "fluentbit" {
  name      = "fluent-bit-hubble-exporter"
  namespace = kubernetes_namespace_v1.cilium.metadata[0].name

  repository = "oci://ghcr.io/fluent/helm-charts/"
  chart      = "fluent-bit-collector"
  version    = "1.1.3"

  values = [yamlencode({
    automountServiceAccountToken = true
    storage = {
      enabled = true
    }
    config = {
      service = {
        flush     = 5
        log_level = "info"
      }
      parsers = [
        {
          name        = "hubble-export"
          format      = "json"
          time_format = "%Y-%m-%dT%H:%M:%S.%L%z"
        }
      ]
      pipeline = {
        inputs = [
          {
            name             = "tail"
            alias            = "hubble-export"
            path             = "/var/run/cilium/hubble/events.log"
            tag              = "hubble.*"
            parser           = "hubble-export"
            refresh_interval = 5
            rotate_wait      = 30
            "storage.type"   = "$${STORAGE_TYPE_PREFER_FS}"
            db               = "$${STORAGE_PATH}/hubble-export-tail.db"
          }
        ]

        filters = [
          // The grep filter cannot perform regex matches against non-string
          // types, and flow.event_type.type is an integer. Instead of using
          // lua we could use a filter to type convert the flow.event_type.type
          // field to a string, and then use a filter grep for it being 4,
          // however doing so will leave the type incorrect in the final log
          // entry, which means the actual log structure would deviate from the
          // hubble flow logs docs and api spec, so you'd want to convert it
          // back again. In the end it seems easier and safer to use a small
          // lua function to do the matching. Returning 0 means keep the log
          // untouched, returning -1 means drop the log.
          {
            name  = "lua"
            match = "hubble.*"
            call  = "filter_for_new_traces"
            code  = <<-END_OF_LUA
              function filter_for_new_traces(tag, timestamp, record)
                local flow = record["flow"]
                if type(flow) == "table"
                  and type(flow["event_type"]) == "table"
                  and flow["event_type"]["type"] == 4
                  and flow["trace_reason"] == "NEW"
                  then return 0, timestamp, record
                end
                return -1, timestamp, record
              end
              END_OF_LUA
          },
          {
            name         = "nest"
            match        = "hubble.*"
            operation    = "lift"
            nested_under = "flow"
            add_prefix   = "flow_"
          },
          {
            name         = "nest"
            match        = "hubble.*"
            operation    = "lift"
            nested_under = "flow_source"
            add_prefix   = "source_"
          },
          {
            name  = "modify"
            match = "hubble.*"
            remove = [
              "flow_emitter",
              "flow_ethernet",
              "flow_node_name",
              "flow_node_labels",
              "flow_event_type",
              "flow_trace_observation_point",
              "flow_trace_reason",
              "flow_is_reply",
              "flow_Summary",
              "source_ID",
              "source_identity",
              "source_cluster_name",
              "source_labels",
              "node_name",
            ]
          },
          {
            name          = "nest"
            match         = "hubble.*"
            operation     = "nest"
            wildcard      = "source_*"
            nest_under    = "flow_source"
            remove_prefix = "source_"
          },
          {
            name          = "nest"
            match         = "hubble.*"
            operation     = "nest"
            wildcard      = "flow_*"
            nest_under    = "flow"
            remove_prefix = "flow_"
          },
        ]
        outputs = [
          {
            name   = "stdout"
            alias  = "out"
            format = "json_lines"
            match  = "hubble.*"
          }
        ]
      }
    }
    hostVolumes = [
      // This first volume is included by default and we should keep it so fluent bit can augment the logs
      {
        name      = "machine-id"
        mountPath = "/etc/machine-id"
        hostPath = {
          path = "/etc/machine-id"
          type = "File"
        }
        }, {
        name      = "hubble-export"
        mountPath = "/var/run/cilium/hubble"
        hostPath = {
          path = "/var/run/cilium/hubble"
          type = "Directory"
        }
      }
    ]
  })]
}
