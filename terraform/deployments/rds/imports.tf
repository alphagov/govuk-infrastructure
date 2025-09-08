import {
  to = aws_db_instance.instance["link_checker_api"]
  id = "link-checker-api-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["link_checker_api"]
  id = "staging-link-checker-api-postgres-20250827092600496900000002"
}