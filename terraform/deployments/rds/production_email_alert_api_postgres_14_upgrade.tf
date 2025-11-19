import {
  to = aws_db_instance.instance["email_alert_api"]
  id = "email-alert-api-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["email_alert_api"]
  id = "production-email-alert-api-postgres-2025082811531767830000000b"
}