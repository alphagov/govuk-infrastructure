locals {
  flow_log_import = {
    integration = "fl-03092d4a72be977ef"
    staging     = "fl-0b3a7beb7a58472f0"
    production  = "fl-0cdc3d86925dbe9b4"
  }
}

import {
  to = aws_flow_log.vpc_flow_log
  id = local.flow_log_import[var.govuk_environment]
}

import {
  to = aws_cloudwatch_log_group.log
  id = "govuk-vpc-flow-log"
}

import {
  to = google_storage_bucket_access_control.google_logging
  id = "${google_storage_bucket.google_logging.name}/group-cloud-storage-analytics@google.com"
}
