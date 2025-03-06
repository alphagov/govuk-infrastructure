terraform {
  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 1.20.0"
    }
  }

  required_version = "~> 1.10"
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
