import {
  to = aws_db_instance.instance["support_api"]
  id = "support-api-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["support_api"]
  id = "staging-support-api-postgres-20250827092600496800000001"
}