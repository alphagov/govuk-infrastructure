import {
  to = aws_db_instance.instance["email_alert_api"]
  id = "email-alert-api-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["email_alert_api"]
  id = "staging-email-alert-api-postgres-20250828115303736100000009"
}