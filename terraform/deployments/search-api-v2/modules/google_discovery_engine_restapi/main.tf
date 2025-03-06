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

############## ENGINE ##############

module "serving_config_default" {
  source = "../serving_config"

  id           = "default_search"
  display_name = "Default (used by live Search API v2)"
  engine_id    = var.engine_id

  boost_control_ids = [
    module.control_boost_demote_low.id,
    module.control_boost_demote_medium.id,
    module.control_boost_demote_pages.id,
    module.control_boost_demote_strong.id,
    module.control_boost_promote_low.id,
    module.control_boost_promote_medium.id,
  ]
  synonyms_control_ids = [
    module.control_synonym_hmrc.id,
  ]
}

module "control_boost_promote_medium" {
  source = "../control"

  id           = "boost_promote_medium"
  display_name = "Boost: Promote medium"
  engine_id    = var.engine_id
  action = {
    boostAction = {
      filter = "content_purpose_supergroup: ANY(\"services\") OR document_type: ANY(\"calendar\", \"detailed_guide\", \"document_collection\", \"external_content\", \"organisation\")",
      boost  = 0.2
    }
  }
}

module "control_boost_promote_low" {
  source = "../control"

  id           = "boost_promote_low"
  display_name = "Boost: Promote low"
  engine_id    = var.engine_id
  action = {
    boostAction = {
      filter = "document_type: ANY(\"guidance\", \"mainstream_browse_page\", \"policy_paper\", \"travel_advice\")",
      boost  = 0.05
    }
  }
}

module "control_boost_demote_low" {
  source = "../control"

  id           = "boost_demote_low"
  display_name = "Boost: Demote low"
  engine_id    = var.engine_id
  action = {
    boostAction = {
      filter = "document_type: ANY(\"about\", \"taxon\", \"world_news_story\")",
      boost  = -0.25
    }
  }
}

module "control_boost_demote_medium" {
  source = "../control"

  id           = "boost_demote_medium"
  display_name = "Boost: Demote medium"
  engine_id    = var.engine_id
  action = {
    boostAction = {
      filter = "document_type: ANY(\"employment_tribunal_decision\", \"foi_release\", \"service_standard_report\") OR organisation_state: ANY(\"devolved\", \"closed\")",
      boost  = -0.5
    }
  }
}

module "control_boost_demote_strong" {
  source = "../control"

  id           = "boost_demote_strong"
  display_name = "Boost: Demote strong"
  engine_id    = var.engine_id
  action = {
    boostAction = {
      filter = "is_historic = 1",
      boost  = -0.75
    }
  }
}

module "control_boost_demote_pages" {
  source = "../control"

  id           = "boost_demote_pages"
  display_name = "Boost: Demote specific pages"
  engine_id    = var.engine_id
  action = {
    boostAction = {
      filter = "link: ANY(\"/government/publications/pension-credit-claim-form--2\")",
      boost  = -0.75
    }
  }
}

module "control_synonym_hmrc" {
  source = "../control"

  id           = "syn_hmrc"
  display_name = "Synonyms: HMRC"
  engine_id    = var.engine_id
  action = {
    synonymsAction = {
      synonyms = [
        "inland revenue",
        "hmrc",
        "hm revenue and customs",
      ]
    }
  }
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
