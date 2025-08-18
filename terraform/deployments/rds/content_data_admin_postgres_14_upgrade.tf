import {
  to = aws_db_instance.instance["content_data_admin"]
  id = "content-data-admin-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["content_data_admin"]
  id = "staging-content-data-admin-postgres-20250818103201143300000001"
}
