import {
  to = aws_db_instance.instance["transition"]
  id = "transition-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["transition"]
  id = "staging-transition-postgres-20250908163308605600000001"
}
