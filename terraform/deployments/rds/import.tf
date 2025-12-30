import {
  to = aws_db_instance.instance["publishing_api"]
  id = "publishing-api-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["publishing_api"]
  id = "production-publishing-api-postgres-20251217151217242100000001"
}

import {
  to = aws_db_instance.replica["publishing_api"]
  id = "production-publishing-api-postgres-replica"
}
