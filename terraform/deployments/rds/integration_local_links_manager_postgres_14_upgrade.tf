import {
  to = aws_db_instance.instance["local_links_manager"]
  id = "local-links-manager-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["local_links_manager"]
  id = "integration-local-links-manager-postgres-20250828113749103100000002"
}