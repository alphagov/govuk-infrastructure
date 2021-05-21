enable_cdn                       = true
cdn_certificate_validation_cname = { name = "_acme-challenge.www.ecs.test.govuk.digital", record = "imu53najhaviy4ov80.fastly-validations.com" }

#--------------------------------------------------------------
# App
#--------------------------------------------------------------

# Apps that have workers and that we can spin down to avoid potential conflict
# with EC2-based workers
publisher_worker_desired_count      = 1
publishing_api_worker_desired_count = 1


# Only specific config supported. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size
content_store_cpu    = 2048
content_store_memory = 4096
