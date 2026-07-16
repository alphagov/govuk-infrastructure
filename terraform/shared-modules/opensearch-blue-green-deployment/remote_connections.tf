resource "terraform_data" "blue_domain_replacement" {
  triggers_replace = var.launch_blue_domain ? module.blue_domain[0].opensearch_endpoint : null
}

resource "terraform_data" "green_domain_replacement" {
  triggers_replace = var.launch_green_domain ? module.green_domain[0].opensearch_endpoint : null
}

resource "aws_opensearch_outbound_connection" "to_green_from_blue" {
  // The connection for import is done the opposite direction to the direction of the data flow.
  // So if you are copying to green from blue, the remote connection has to go to blue from green
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

  lifecycle {
    replace_triggered_by = [
      terraform_data.blue_domain_replacement,
      terraform_data.green_domain_replacement,
    ]
  }
}

resource "aws_opensearch_authorize_vpc_endpoint_access" "blue" {
  count = var.create_remote_connection_to_import_to_green_from_blue || (
    var.launch_blue_domain && var.blue_cluster_options != null && var.blue_cluster_options.create_vpc_endpoint
  ) ? 1 : 0

  domain_name = module.blue_domain[0].opensearch_domain_name
  account     = data.aws_caller_identity.current.account_id
  region      = data.aws_region.current.name

  lifecycle {
    replace_triggered_by = [
      terraform_data.blue_domain_replacement,
    ]
  }
}

resource "aws_opensearch_outbound_connection" "to_blue_from_green" {
  // The connection for import is done the opposite direction to the direction of the data flow.
  // So if you are copying to blue from green, the remote connection has to go to green from blue
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

  lifecycle {
    replace_triggered_by = [
      terraform_data.blue_domain_replacement,
      terraform_data.green_domain_replacement,
    ]
  }
}

resource "aws_opensearch_authorize_vpc_endpoint_access" "green" {
  count = var.create_remote_connection_to_import_to_blue_from_green || (
    var.launch_green_domain && var.green_cluster_options != null && var.green_cluster_options.create_vpc_endpoint
  ) ? 1 : 0

  domain_name = module.green_domain[0].opensearch_domain_name
  account     = data.aws_caller_identity.current.account_id
  region      = data.aws_region.current.name

  lifecycle {
    replace_triggered_by = [
      terraform_data.blue_domain_replacement,
      terraform_data.green_domain_replacement,
    ]
  }
}
