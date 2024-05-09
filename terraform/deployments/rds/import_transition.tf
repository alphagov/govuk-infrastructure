import {
  to = aws_db_instance.instance["transition"]
  id = "blue-transition-postgresql-primary"
}

import {
  to = aws_route53_record.instance_cname["transition"]
  id = "${data.terraform_remote_state.infra_root_dns_zones.outputs.internal_root_zone_id}_transition-postgres.${var.govuk_environment}.govuk-internal.digital_CNAME"
}
