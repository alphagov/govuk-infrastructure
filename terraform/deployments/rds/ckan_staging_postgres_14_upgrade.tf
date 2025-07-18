import {
  to = aws_db_instance.instance["ckan"]
  id = "ckan-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["ckan"]
  id = "staging-ckan-postgres-20250704093728599800000001"
}
