publishing_service_domain = "test.publishing.service.gov.uk"
internal_app_domain       = "test.govuk-internal.digital"
external_app_domain       = "test.govuk.digital"

#--------------------------------------------------------------
# App variables
#--------------------------------------------------------------

govuk_environment = "test"
redis_host        = "shared-redis.test.govuk-internal.digital"

#--------------------------------------------------------------
# Network
#--------------------------------------------------------------

# TODO: When it becomes possible, pull these from Terraform "data" type
mesh_domain       = "mesh.govuk-internal.digital"
mesh_name         = "govuk"
office_cidrs_list = ["213.86.153.212/32", "213.86.153.213/32", "213.86.153.214/32", "213.86.153.235/32", "213.86.153.236/32", "213.86.153.237/32", "85.133.67.244/32"]

# TODO: Move into a monitoring tfvars file.
concourse_cidrs_list = ["35.178.226.106/32", "18.130.168.3/32"]
