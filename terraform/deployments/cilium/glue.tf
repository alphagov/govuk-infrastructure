resource "aws_glue_catalog_table" "hubble_export_new_traces" {
  // using hyphens in the table name is annoying since you have to always double quote it in athena, so use underscores
  name          = "hubble_export_new_traces_${replace(var.govuk_environment, "-", "_")}"
  database_name = "default"
  table_type    = "EXTERNAL_TABLE"

  partition_keys {
    name    = "dt"
    comment = "Date in YYYY-MM-DD format of the partition"
    type    = "string"
  }

  partition_keys {
    name    = "h"
    comment = "Hour in HH format of the partition"
    type    = "string"
  }

  storage_descriptor {
    location = "s3://${module.hubble_logs_bucket.name}/${local.hubble_log_s3_path_prefix}/${local.hubble_log_s3_file_format}/"

    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    stored_as_sub_directories = true

    compressed = true

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"

      parameters = {
        paths = "date,flow"
      }
    }

    columns {
      name = "date"
      // If we use the date type we will lose the microsecond precision, and we don't actually need to
      // query based on date any more granularly than the dt partitions, so lets keep it as a string
      type = "string"
    }

    columns {
      name = "flow"
      // We can't use a struct because the fields vary between log entries, we can use json_extract in ATHENA
      // to extract the data we actually need to operator on
      type = "string"
    }
  }

  parameters = {
    "classification"  = "json"
    "compressionType" = "gzip"
    "EXTERNAL"        = "TRUE"

    // Athena Partition Projection Configuration, this means we don't need a partition index, and
    // new paritions are automatically available instead of having to run queries to update the
    // available paritions
    "projection.enabled" = "true"

    # Date Partition (dt=YYYY-MM-DD)
    "projection.dt.type"          = "date"
    "projection.dt.format"        = "yyyy-MM-dd"
    "projection.dt.range"         = "2026-11-24,NOW" # Adjust start date as needed
    "projection.dt.interval"      = "1"
    "projection.dt.interval.unit" = "DAYS"

    # Hour Partition (h=HH)
    "projection.h.type"   = "integer"
    "projection.h.range"  = "0,23"
    "projection.h.digits" = "2" # Ensures leading zeros (00, 01, ..., 23)

    "storage.location.template" = "s3://${local.hubble_log_s3_bucket_name}/${local.hubble_log_s3_path_prefix}/${local.hubble_log_s3_file_format}/dt=$${dt}/h=$${h}/"
  }
}
