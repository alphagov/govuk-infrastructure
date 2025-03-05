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
  boostControls    = yamldecode(file("${path.module}/files/controls/boosts.yml"))
  synonymsControls = yamldecode(file("${path.module}/files/controls/synonyms.yml"))
}

############## DATASTORE ##############

# The data schema for the datastore
#
# The API resource relationship is one-to-many, but currently only a single schema is supported and
# it's automatically created as `default_schema` (with an empty content) on creation of the
# datastore.
#
# API resource: v1alpha.projects.locations.collections.dataStores.schemas


resource "restapi_object" "discovery_engine_datastore_schema" {
  path      = "/dataStores/${var.datastore_id}/schemas"
  object_id = "default_schema"

  # Since the default schema is created automatically with the datastore, we need to update even on
  # initial Terraform resource creation
  create_method = "PATCH"
  create_path   = "/dataStores/${var.datastore_id}/schemas/default_schema"

  data = jsonencode({
    jsonSchema = file("${path.module}/files/datastore_schema.json")
  })
}

############## ENGINE ##############

module "serving_config_default" {
  source = "../serving_config"

  id           = "default_search"
  display_name = "Default (used by live Search API v2)"
  engine_id    = var.engine_id

  boost_control_ids    = keys(local.boostControls)
  synonyms_control_ids = keys(local.synonymsControls)

  # TODO: We can probably remove this once we have visible dependencies in this file and don't
  # create controls through YAML
  depends_on = [local.boostControls, local.synonymsControls]
}

resource "restapi_object" "discovery_engine_boost_control" {
  for_each = local.boostControls

  path      = "/engines/${var.engine_id}/controls"
  object_id = each.key

  # API uses query strings to specify ID of the resource to create (not payload)
  create_path = "/engines/${var.engine_id}/controls?controlId=${each.key}"

  data = jsonencode({
    name        = each.key
    displayName = each.key

    solutionType = "SOLUTION_TYPE_SEARCH"
    useCases     = ["SEARCH_USE_CASE_SEARCH"]

    boostAction = {
      boost     = lookup(each.value, "boost", 0.00000001),
      filter    = lookup(each.value, "filter", ""),
      dataStore = var.datastore_path
    }
  })
}

resource "restapi_object" "discovery_engine_synonym_control" {
  for_each = local.synonymsControls

  path      = "/engines/${var.engine_id}/controls"
  object_id = each.key

  # API uses query strings to specify ID of the resource to create (not payload)
  create_path = "/engines/${var.engine_id}/controls?controlId=${each.key}"

  data = jsonencode({
    name        = each.key
    displayName = each.key

    solutionType = "SOLUTION_TYPE_SEARCH"
    useCases     = ["SEARCH_USE_CASE_SEARCH"]

    synonymsAction = {
      synonyms = each.value
    }
  })
}

resource "restapi_object" "discovery_engine_datastore_completion_config" {
  path      = "/dataStores/${var.datastore_id}/completionConfig"
  object_id = "completionConfig"

  # Since the default completionConfig is created automatically with the datastore, we need to update even on
  # initial Terraform resource creation
  create_method = "PATCH"
  create_path   = "/dataStores/${var.datastore_id}/completionConfig"
  update_method = "PATCH"
  update_path   = "/dataStores/${var.datastore_id}/completionConfig?updateMask=name,matching_order,max_suggestions,min_prefix_length,query_model,enable_mode"
  read_path     = "/dataStores/${var.datastore_id}/completionConfig"

  data = jsonencode({
    name            = "completionConfig"
    matchingOrder   = "out-of-order"
    maxSuggestions  = 5,
    minPrefixLength = 3,
    queryModel      = "automatic",
    enableMode      = "AUTOMATIC"
  })
}

# resource "restapi_object" "discovery_engine_datastore_completion_denylist" {

#   path      = "/dataStores/${var.datastore_id}/suggestionDenyListEntries"
#   object_id = "suggestionDenyListEntries"

#   create_method = "POST"
#   create_path   = "/dataStores/${var.datastore_id}/suggestionDenyListEntries:import"
#   update_method = "POST"
#   update_path   = "/dataStores/${var.datastore_id}/suggestionDenyListEntries:import"

#   data = jsonencode({
#     gcsSource = {
#       inputUris = [
#         "gs://${var.storage_bucket_name}/denylist.jsonl"
#       ]
#     }
#   })
# }
