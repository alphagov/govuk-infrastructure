import {
  to = aws_db_instance.instance["locations_api"]
  id = "locations-api-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["locations_api"]
  id = "integration-locations-api-postgres-20250828113749103400000006"
}
