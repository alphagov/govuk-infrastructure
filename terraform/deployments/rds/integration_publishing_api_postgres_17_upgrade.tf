import {
  to = aws_db_instance.normalised_instance["publishing_api"]
  id = "publishing-api-integration-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["publishing_api"]
  id = "integration-publishing-api-postgres-20251218115310078800000001"
}

import {
  to = aws_db_instance.normalised_replica["publishing_api"]
  id = "publishing-api-integration-postgres-replica"
}
