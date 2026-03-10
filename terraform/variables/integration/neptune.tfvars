govuk_environment = "integration"
aws_region        = "eu-west-1"

neptune_dbs = {
  ai_accelerator = {
    name               = "ai-accelerator"
    instance_class     = "db.t4g.medium"
    instance_count     = 3
    cluster_identifier = "ai-accelerator"
    engine             = "neptune"
    engine_version     = "1.4.6.3"
    family             = "neptune1.4"
    serverless_config = {
      max_capacity = 128
      min_capacity = 1
    }
    cluster_parameter_group_name = "clust_ai_accelerator"
    cluster_parameter_group = [{
      name         = "neptune_enable_audit_log"
      value        = 1
      apply_method = "pending-reboot"
    }]
    iam_roles                      = []
    deletion_protection            = true
    enable_cloudwatch_logs_exports = ["audit"]
    internal_cname_domains_enabled = true
    instance_parameter_group_name  = "inst_eph_ai_accelerator"
    instance_parameter_group = [{
      name         = "neptune_query_timeout"
      value        = "25"
      apply_method = "pending-reboot"
    }]
  }
}
