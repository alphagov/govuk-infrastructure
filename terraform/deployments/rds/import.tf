import {
  to = aws_db_instance.instance["ckan"]
  id = "ckan-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["ckan"]
  id = "integration-ckan-postgres-20250305112304940000000016"
}