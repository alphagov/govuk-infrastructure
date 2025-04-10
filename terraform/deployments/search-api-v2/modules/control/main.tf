terraform {
  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 2.0.0"
    }
  }

  required_version = "~> 1.10"
}

locals {
  path = "/engines/${var.engine_id}/controls"

  dynamic_properties = {
    displayName = var.display_name
    conditions  = length(var.conditions) > 0 ? var.conditions : null
  }
  # These properties are required on creation, but not updatable
  static_properties = {
    solutionType = "SOLUTION_TYPE_SEARCH"
    useCases     = ["SEARCH_USE_CASE_SEARCH"]
  }
  properties = merge(local.dynamic_properties, local.static_properties, var.action)

  # Extract and format the subkeys of the action object for use in the updateMask
  # for example: boostAction.filter, boostAction.boost
  action_keys = flatten([
    for key, value in var.action : [
      for subkey in keys(value) : "${key}.${subkey}"
      if subkey != "dataStore" # immutable subkey used in several action types
    ] if can(keys(value))
  ])

  update_mask = join(",", concat(keys(local.dynamic_properties), local.action_keys))
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
