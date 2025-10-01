import {
  to = aws_db_instance.instance["content_data_api"]
  id = "blue-content-data-api-postgresql-primary-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["content_data_api"]
  id = "staging-content-data-api-postgres-20250929154152068300000001"
}
