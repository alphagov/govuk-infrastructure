import {
  to = aws_db_instance.instance["local_links_manager"]
  id = "local-links-manager-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["local_links_manager"]
  id = "production-local-links-manager-postgres-20250828115316247400000006"
}
