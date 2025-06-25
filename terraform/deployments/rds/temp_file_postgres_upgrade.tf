# resource "aws_db_parameter_group" "postgresql14_green_params" {
#
#   name_prefix = "${var.govuk_environment}-ckan-postgres-"
#   family      = "postgres14"
#
#   parameter {
#     name         = "rds.logical_replication"
#     value        = "1"
#     apply_method = "pending-reboot"
#   }
#
#   parameter {
#     name         = "max_logical_replication_workers"
#     value        = "20"
#     apply_method = "pending-reboot"
#   }
#
#   parameter {
#     name         = "max_worker_processes"
#     value        = "25"
#     apply_method = "pending-reboot"
#   }
#
#   lifecycle { create_before_destroy = true }
#
# }

removed {
  from = aws_db_instance.instance["ckan"]
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_db_parameter_group.engine_params["ckan"]
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_db_parameter_group.postgresql14_green_params
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_cloudwatch_metric_alarm.rds_freestoragespace["ckan"]
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_db_event_subscription.subscription["ckan"]
  lifecycle {
    destroy = false
  }
}


removed {
  from = aws_route53_record.instance_cname["ckan"]
  lifecycle {
    destroy = false
  }
}