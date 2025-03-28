removed {
  from = google_storage_bucket.google_logging

  lifecycle {
    destroy = false
  }
}

removed {
  from = google_storage_bucket_access_control.google_logging

  lifecycle {
    destroy = false
  }
}
removed {
  from = google_storage_bucket_access_control.google_logging

  lifecycle {
    destroy = false
  }
}
removed {
  from = aws_iam_policy.govuk_aws_logging_replication_policy

  lifecycle {
    destroy = false
  }
}
removed {
  from = aws_s3_bucket.aws_logging

  lifecycle {
    destroy = false
  }
}
removed {
  from = aws_s3_bucket_lifecycle_configuration.aws_logging

  lifecycle {
    destroy = false
  }
}
removed {
  from = aws_s3_bucket_policy.aws_logging

  lifecycle {
    destroy = false
  }
}
removed {
  from = aws_s3_bucket_versioning.aws_logging

  lifecycle {
    destroy = false
  }
}
removed {
  from = aws_cloudwatch_log_group.log

  lifecycle {
    destroy = false
  }
}
removed {
  from = aws_flow_log.vpc_flow_log

  lifecycle {
    destroy = false
  }
}
removed {
  from = aws_iam_policy.vpc_flow_logs_policy

  lifecycle {
    destroy = false
  }
}
removed {
  from = aws_iam_role_policy_attachment.govuk_aws_logging_replication_policy_attachment

  lifecycle {
    destroy = false
  }
}
removed {
  from = aws_iam_role_policy_attachment.rds_enhanced_monitoring

  lifecycle {
    destroy = false
  }
}
removed {
  from = aws_iam_role_policy_attachment.vpc_flow_logs_policy_attachment

  lifecycle {
    destroy = false
  }
}
removed {
  from = aws_iam_role.govuk_aws_logging_replication_role

  lifecycle {
    destroy = false
  }
}
removed {
  from = aws_iam_role.rds_enhanced_monitoring

  lifecycle {
    destroy = false
  }
}
removed {
  from = aws_iam_role.vpc_flow_logs_role

  lifecycle {
    destroy = false
  }
}
removed {
  from = aws_s3_bucket_acl.aws_logging

  lifecycle {
    destroy = false
  }
}
removed {
  from = aws_s3_bucket_replication_configuration.aws_logging

  lifecycle {
    destroy = false
  }
}
