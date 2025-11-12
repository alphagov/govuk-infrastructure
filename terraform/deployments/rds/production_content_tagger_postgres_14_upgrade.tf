import {
  to = aws_db_instance.instance["content_tagger"]
  id = "content-tagger-postgres"
}

import {
  to = aws_db_parameter_group.engine_params["content_tagger"]
  id = "production-content-tagger-postgres-2025082811531774370000000c"
}