import {
  to = aws_db_instance.instance["locations_api"]
  id = "locations-api-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["locations_api"]
  id = "staging-locations-api-postgres-20250828115303735800000005"
}