import {
  to = aws_db_instance.instance["content_tagger"]
  id = "content-tagger-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["content_tagger"]
  id = "integration-content-tagger-postgres-20250828113749104100000007"
}
