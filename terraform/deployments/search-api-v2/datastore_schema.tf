resource "restapi_object" "google_discovery_engine_datastore_schema" {
  path      = "/dataStores/${google_discovery_engine_data_store.govuk_content.data_store_id}/schemas"
  object_id = "default_schema"

  data = jsonencode({
    structSchema = {
      "$schema" = "https://json-schema.org/draft/2020-12/schema"
      type      = "object"
      properties = {
        # Unique content ID from the Publishing API (for debugging/retrieving single objects)
        content_id = {
          type        = "string"
          retrievable = true
        }
        # Unique identifier for search quality evaluation (identical to content_id)
        #
        # Note: This is only used to compare results for evaluation purposes, and is not a URL
        # despite the name. We decided against using the alternative 'uri' field name to avoid
        # confusion with our existing 'url' field and 'uri' key property (see
        # https://cloud.google.com/generative-ai-app-builder/docs/evaluate-search-quality)
        cdoc_url = {
          type        = "string"
          retrievable = true
        }
        # The main title (shown in search results)
        title = {
          type               = "string"
          keyPropertyMapping = "title"
          retrievable        = true
        }
        # A short description (shown in search results)
        description = {
          type               = "string"
          keyPropertyMapping = "description"
          retrievable        = true
        }
        # Additional textual content such as keywords that should be searchable but don't form part
        # of the main body of content
        #
        # Note: We've decided not to use this as structured fields don't contribute enough to
        # relevance. Vertex does not support removing a field from the schema (as of Jan 2024) so it
        # stays here.
        additional_searchable_text = {
          type       = "string"
          searchable = true
        }
        # URI reference either as a relative path for GOV.UK content, or as an absolute URL for
        # external content (used to link to the content from search results)
        link = {
          type        = "string"
          retrievable = true
          indexable   = true
        }
        # Absolute URL including protocol and host even for content on GOV.UK proper (used for
        # Vertex to incorporate popularity/event signals and for internal purposes)
        url = {
          type               = "string"
          retrievable        = true
          keyPropertyMapping = "uri"
        }
        # Unix timestamp of when this object was last updated (for sorting/filtering/boosting)
        public_timestamp = {
          type        = "integer"
          retrievable = true
          indexable   = true
        }
        # RFC3339 timestamp of when this object was last updated (for boosting and displaying)
        public_timestamp_datetime = {
          type        = "datetime"
          retrievable = true
          indexable   = true
        }
        # The source document type (for boosting)
        document_type = {
          type        = "string"
          indexable   = true
          retrievable = true
        }
        # The content purpose supergroup (for filtering/boosting)
        content_purpose_supergroup = {
          type        = "string"
          indexable   = true
          retrievable = true
        }
        # A list of GOV.UK taxon IDs that this content object is tagged to (for filtering)
        part_of_taxonomy_tree = {
          type = "array"
          items = {
            type               = "string"
            keyPropertyMapping = "category"
          }
        }
        # Whether the content is historic (for boosting; boosts don't support boolean)
        is_historic = {
          type        = "integer"
          indexable   = true
          retrievable = true
        }
        # The state of the organisation (for boosting)
        organisation_state = {
          type      = "string"
          indexable = true
        }
        # The name of the government under which the content was originally created (shown as part
        # of search result if present)
        government_name = {
          type        = "string"
          retrievable = true
        }
        # The locale of the content (not used yet, may be useful for i18n later)
        locale = {
          type      = "string"
          indexable = true
        }
        # A list of parts (shown below search result if present)
        parts = {
          type = "array"
          items = {
            type = "object"
            properties = {
              title = {
                type        = "string"
                searchable  = true
                retrievable = true
              }
              body = {
                type        = "string"
                searchable  = true
                retrievable = true
              }
              slug = {
                type        = "string"
                retrievable = true
              }
            }
          }
        }
        # A list of organisation slugs this content belongs to (for filtering)
        organisations = {
          type = "array"
          items = {
            type      = "string"
            indexable = true
          }
        }
        # A list of topical events slugs this content belongs to (for filtering)
        topical_events = {
          type = "array"
          items = {
            type      = "string"
            indexable = true
          }
        }
        # A list of world locations slugs this content belongs to (for filtering)
        world_locations = {
          type = "array"
          items = {
            type      = "string"
            indexable = true
          }
        }
        # The manual this content belongs to (if applicable) (for filtering)
        manual = {
          type      = "string"
          indexable = true
        }
        # Incrementing document version number (used to avoid document update race conditions)
        #
        # Note: We've decided not to use this in the end as there isn't enough of a risk and we
        # cannot guarantee atomic writes anyway. It is now included in the `debug` object field.
        # Vertex does not support removing a field from the schema (as of Jan 2024) so it stays
        # here.
        payload_version = {
          type = "integer"
        }
        # Metadata that is only used for debugging purposes
        debug = {
          type        = "object"
          retrievable = false
          properties = {
            # Incrementing version number of an export run from Publishing API
            payload_version = {
              type = "integer"
            }
            # Timestamp of when this document was last synced to Vertex
            last_synced_at = {
              type = "string"
            }
          }
        }
      }
    }
  })

  # VAIS adds some "output-only" properties dynamically, which creates false positive drift.
  # Terraform also alphabetises the properties, which again causes false positive drift (as VAIS
  # returns them in undefined order)
  ignore_changes_to = [
    "fieldConfigs",
    "structSchema",
    "name"
  ]
}
