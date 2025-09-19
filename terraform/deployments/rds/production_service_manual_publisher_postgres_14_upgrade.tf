import {
  to = aws_db_instance.instance["service_manual_publisher"]
  id = "service-manual-publisher-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["service_manual_publisher"]
  id = "production-service-manual-publisher-postgres-20250917085919426400000001"
}

import {
  to = aws_db_parameter_group.engine_params["ckan"]
  id = "production-ckan-postgres-20250721153103318500000001"
}
