terraform {
  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 1.20.0"
    }
  }

  required_version = "~> 1.10"
}

locals {
  path = "/engines/${var.engine_id}/controls"

  dynamic_properties = merge({
    displayName = var.display_name
  }, var.action)
  # These properties are required on creation, but not updatable
  static_properties = {
    solutionType = "SOLUTION_TYPE_SEARCH"
    useCases     = ["SEARCH_USE_CASE_SEARCH"]
  }
  properties = merge(local.dynamic_properties, local.static_properties)

  update_mask = join(",", keys(local.dynamic_properties))
}

resource "restapi_object" "control" {
  path      = local.path
  object_id = var.id
  data      = jsonencode(local.properties)

  # On creation, instead of in the path or as part of the data, the API expects the ID of the object
  # to be passed as a query parameter
  create_path = "${local.path}?controlId=${var.id}"

  # Set updateMask to ensure we don't accidentally overwrite other fields with `null`
  update_path = "${local.path}/${var.id}?updateMask=${local.update_mask}"
}
