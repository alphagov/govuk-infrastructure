import {
  to = aws_db_instance.instance["service_manual_publisher"]
  id = "service-manual-publisher-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["service_manual_publisher"]
  id = "staging-service-manual-publisher-postgres-20250916122007110200000001"
}
