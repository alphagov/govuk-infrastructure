import {
  to = aws_db_instance.instance["transition"]
  id = "transition-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["transition"]
  id = "integration-transition-postgres-20250826151928116600000001"
}
