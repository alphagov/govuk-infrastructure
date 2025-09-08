import {
  to = aws_db_instance.instance["transition"]
  id = "transition-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["transition"]
  id = "production-transition-postgres-2025030515232551360000000d"
}

import {
  to = aws_db_parameter_group.transition_postgresql_14_green_params
  id = "production-transition-postgres-20250828115316248400000008"
}