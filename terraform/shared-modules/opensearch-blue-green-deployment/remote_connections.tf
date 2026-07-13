resource "aws_opensearch_outbound_connection" "to_green_from_blue" {
  count = var.create_remote_connection_to_import_to_blue_from_green ? 1 : 0

  connection_alias = "${var.opensearch_domain_name}-connection-to-green-from-blue"
  connection_mode  = "VPC_ENDPOINT"

  local_domain_info {
    owner_id    = data.aws_caller_identity.current.account_id
    region      = data.aws_region.current.name
    domain_name = module.blue_domain[0].opensearch_domain_name
  }

  remote_domain_info {
    owner_id    = data.aws_caller_identity.current.account_id
    region      = data.aws_region.current.name
    domain_name = module.green_domain[0].opensearch_domain_name
  }

  accept_connection = true
}

resource "aws_opensearch_outbound_connection" "to_blue_from_green" {
  count = var.create_remote_connection_to_import_to_green_from_blue ? 1 : 0

  connection_alias = "${var.opensearch_domain_name}-connection-to-blue-from-green"
  connection_mode  = "VPC_ENDPOINT"

  local_domain_info {
    owner_id    = data.aws_caller_identity.current.account_id
    region      = data.aws_region.current.name
    domain_name = module.green_domain[0].opensearch_domain_name
  }

  remote_domain_info {
    owner_id    = data.aws_caller_identity.current.account_id
    region      = data.aws_region.current.name
    domain_name = module.blue_domain[0].opensearch_domain_name
  }

  accept_connection = true
}
