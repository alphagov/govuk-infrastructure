terraform {
  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 1.19.1"
    }
  }

  required_version = "~> 1.7"
}

locals {
  servingConfigs  = yamldecode(file("${path.module}/files/servingConfigs/servingConfigs.yml"))
  boostControls   = yamldecode(file("${path.module}/files/controls/boosts.yml"))
  synonymControls = yamldecode(file("${path.module}/files/controls/synonyms.yml"))
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

# Default serving config (currently used by search-api-v2, to be superseded by site_search serving
# config)
resource "restapi_object" "discovery_engine_serving_config" {
  depends_on = [
    restapi_object.discovery_engine_boost_control,
    restapi_object.discovery_engine_synonym_control
  ]

  path      = "/engines/${var.engine_id}/servingConfigs/default_search?updateMask=boost_control_ids,synonyms_control_ids"
  object_id = "default_search"

  # Since the default serving config is created automatically with the engine, we need to update
  # even on initial Terraform resource creation
  create_method = "PATCH"
  create_path   = "/engines/${var.engine_id}/servingConfigs/default_search?updateMask=boost_control_ids,synonyms_control_ids"
  update_method = "PATCH"
  update_path   = "/engines/${var.engine_id}/servingConfigs/default_search?updateMask=boost_control_ids,synonyms_control_ids"
  read_path     = "/engines/${var.engine_id}/servingConfigs/default_search"

  data = jsonencode({
    boostControlIds    = keys(local.boostControls)
    synonymsControlIds = keys(local.synonymControls)
  })
}

# Future serving config managed by Search Admin
resource "restapi_object" "discovery_engine_serving_config_site_search" {
  path      = "/engines/${var.engine_id}/servingConfigs/site_search"
  object_id = "site_search"

  create_method = "POST"
  create_path   = "/engines/${var.engine_id}/servingConfigs?servingConfigId=site_search"
  update_method = "PATCH"
  update_path   = "/engines/${var.engine_id}/servingConfigs/site_search"
  read_path     = "/engines/${var.engine_id}/servingConfigs/site_search"

  data = jsonencode({
    displayName  = "Site Search serving config (controls managed by Search Admin)"
    solutionType = "SOLUTION_TYPE_SEARCH"
  })
}

# Handles additional serving configs beyond the default_search serving config
resource "restapi_object" "discovery_engine_serving_config_additional" {
  depends_on = [
    restapi_object.discovery_engine_boost_control,
    restapi_object.discovery_engine_synonym_control
  ]

  for_each = local.servingConfigs

  path      = "/engines/${var.engine_id}/servingConfigs"
  object_id = each.key

  create_method = "POST"
  create_path   = "/engines/${var.engine_id}/servingConfigs?servingConfigId=${each.key}"
  update_method = "PATCH"
  update_path   = "/engines/${var.engine_id}/servingConfigs/${each.key}"
  read_path     = "/engines/${var.engine_id}/servingConfigs/${each.key}"

  data = jsonencode({
    name               = each.key,
    displayName        = each.key,
    solutionType       = "SOLUTION_TYPE_SEARCH",
    boostControlIds    = lookup(each.value, "boostControlIds", []),
    synonymsControlIds = lookup(each.value, "synonymsControlIds", [])
  })
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
  for_each = local.synonymControls

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
