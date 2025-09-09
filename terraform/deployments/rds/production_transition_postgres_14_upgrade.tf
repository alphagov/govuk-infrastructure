import {
  to = aws_db_instance.instance["transition"]
  id = "transition-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["transition"]
  id = "production-transition-postgres-20250909102106888100000001"
}