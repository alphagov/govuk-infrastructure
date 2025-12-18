import {
  to = aws_db_instance.normalised_instance["publishing_api"]
  id = "publishing-api-staging-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["publishing_api"]
  id = "staging-publishing-api-postgres-20251215134108173900000001"
}

import {
  to = aws_db_instance.normalised_replica["publishing_api"]
  id = "publishing-api-staging-postgres-replica"
}