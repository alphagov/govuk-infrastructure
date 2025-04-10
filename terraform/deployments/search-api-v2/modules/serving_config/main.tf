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
  path = "/engines/${var.engine_id}/servingConfigs"

  dynamic_properties = {
    displayName        = var.display_name
    boostControlIds    = var.boost_control_ids
    filterControlIds   = var.filter_control_ids
    synonymsControlIds = var.synonyms_control_ids
  }
  # These properties are required on creation, but not updatable
  static_properties = {
    solutionType = "SOLUTION_TYPE_SEARCH"
  }
  properties = merge(local.dynamic_properties, local.static_properties)

  update_mask = join(",", keys(local.dynamic_properties))
}

resource "restapi_object" "serving_config" {
  path      = local.path
  object_id = var.id
  data      = jsonencode(local.properties)

  # On creation, instead of in the path or as part of the data, the API expects the ID of the object
  # to be passed as a query parameter
  create_path = "${local.path}?servingConfigId=${var.id}"

  # Set updateMask to ensure we don't accidentally overwrite other fields with `null`
  update_path = "${local.path}/${var.id}?updateMask=${local.update_mask}"
}
