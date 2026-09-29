data "aws_lbs" "known_load_balancer_arns" {}
data "aws_lb" "known_load_balancers" {
  for_each = data.aws_lbs.known_load_balancer_arns.arns
  arn      = each.value
}

locals {
  lbs_with_access_logging = {
    for lb in data.aws_lb.known_load_balancers :
    lb.name => { prefix = coalesce(lb.access_logs[0].prefix, "") } if(
      length(lb.access_logs) == 1 &&
      lb.access_logs[0].enabled &&
      lb.access_logs[0].bucket == data.tfe_outputs.logging.nonsensitive_values.aws_logging_bucket_id
    )
  }
}

resource "aws_glue_catalog_database" "alb_logs" {
  name        = "${var.govuk_environment}_alb_logs"
  description = "Contains access logs from application load balancers in the account"
}

resource "aws_glue_catalog_table" "alb_logs" {
  for_each = local.lbs_with_access_logging

  name          = each.key
  description   = "Holds all ALB access logs for load balancer ${each.key} in ${var.govuk_environment} environment"
  database_name = aws_glue_catalog_database.alb_logs.name
  table_type    = "EXTERNAL_TABLE"


  parameters = {
    EXTERNAL             = "TRUE"
    "projection.enabled" = "true"

    "projection.year.type"          = "date"
    "projection.year.range"         = "NOW-6MONTHS,NOW"
    "projection.year.format"        = "yyyy"
    "projection.year.interval"      = "1"
    "projection.year.internal.unit" = "YEARS"

    "projection.month.type"     = "integer"
    "projection.month.range"    = "1,12"
    "projection.month.interval" = "1"
    "projection.month.digits"   = "2"

    "projection.day.type"     = "integer"
    "projection.day.range"    = "1,31"
    "projection.day.interval" = "1"
    "projection.day.digits"   = "2"

    "storage.location.template" = "s3://${data.tfe_outputs.logging.nonsensitive_values.aws_logging_bucket_id}/${each.value.prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/elasticloadbalancing/${data.aws_region.current.region}/$${year}/$${month}/$${day}"
  }

  storage_descriptor {
    location = "s3://${data.tfe_outputs.logging.nonsensitive_values.aws_logging_bucket_id}/${each.value.prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/elasticloadbalancing/${data.aws_region.current.region}/"

    stored_as_sub_directories = true
    input_format              = "org.apache.hadoop.mapred.TextInputFormat"
    output_format             = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    compressed                = true

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.RegexSerDe"
      parameters = {
        "serialization.format" = "1"
        "field.delim"          = " "
        # regex from https://docs.aws.amazon.com/athena/latest/ug/create-alb-access-logs-table.html
        "input.regex" = "([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*):([0-9]*) ([^ ]*)[:-]([0-9]*) ([-.0-9]*) ([-.0-9]*) ([-.0-9]*) (|[-0-9]*) (-|[-0-9]*) ([-0-9]*) ([-0-9]*) \"([^ ]*) (.*) (- |[^ ]*)\" \"([^\"]*)\" ([A-Z0-9-_]+) ([A-Za-z0-9.-]*) ([^ ]*) \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" ([-.0-9]*) ([^ ]*) \"([^\"]*)\" \"([^\"]*)\" \"([^ ]*)\" \"([^\\s]+?)\" \"([^\\s]+)\" \"([^ ]*)\" \"([^ ]*)\" ?([^ ]*)? ?( .*)?"
      }
    }

    # columns sourced from
    # https://docs.aws.amazon.com/athena/latest/ug/create-alb-access-logs-table.html
    columns {
      name = "type"
      type = "string"
    }
    columns {
      name = "time"
      type = "string"
    }
    columns {
      name = "elb"
      type = "string"
    }
    columns {
      name = "client_ip"
      type = "string"
    }
    columns {
      name = "client_port"
      type = "int"
    }
    columns {
      name = "target_ip"
      type = "string"
    }
    columns {
      name = "target_port"
      type = "int"
    }
    columns {
      name = "request_processing_time"
      type = "double"
    }
    columns {
      name = "target_processing_time"
      type = "double"
    }
    columns {
      name = "response_processing_time"
      type = "double"
    }
    columns {
      name = "elb_status_code"
      type = "int"
    }
    columns {
      name = "target_status_code"
      type = "string"
    }
    columns {
      name = "received_bytes"
      type = "bigint"
    }
    columns {
      name = "sent_bytes"
      type = "bigint"
    }
    columns {
      name = "request_verb"
      type = "string"
    }
    columns {
      name = "request_url"
      type = "string"
    }
    columns {
      name = "request_proto"
      type = "string"
    }
    columns {
      name = "user_agent"
      type = "string"
    }
    columns {
      name = "ssl_cipher"
      type = "string"
    }
    columns {
      name = "ssl_protocol"
      type = "string"
    }
    columns {
      name = "target_group_arn"
      type = "string"
    }
    columns {
      name = "trace_id"
      type = "string"
    }
    columns {
      name = "domain_name"
      type = "string"
    }
    columns {
      name = "chosen_cert_arn"
      type = "string"
    }
    columns {
      name = "matched_rule_priority"
      type = "string"
    }
    columns {
      name = "request_creation_time"
      type = "string"
    }
    columns {
      name = "actions_executed"
      type = "string"
    }
    columns {
      name = "redirect_url"
      type = "string"
    }
    columns {
      name = "lambda_error_reason"
      type = "string"
    }
    columns {
      name = "target_port_list"
      type = "string"
    }
    columns {
      name = "target_status_code_list"
      type = "string"
    }
    columns {
      name = "classification"
      type = "string"
    }
    columns {
      name = "classification_reason"
      type = "string"
    }
    columns {
      name = "conn_trace_id"
      type = "string"
    }
  }

  partition_keys {
    name = "year"
    type = "int"
  }

  partition_keys {
    name = "month"
    type = "int"
  }

  partition_keys {
    name = "day"
    type = "int"
  }

}
