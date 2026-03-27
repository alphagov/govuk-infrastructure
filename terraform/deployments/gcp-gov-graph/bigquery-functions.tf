# A dataset of user-defined functions and remote functions

resource "google_bigquery_dataset" "functions" {
  dataset_id            = "functions"
  friendly_name         = "functions"
  description           = "User-defined functions and remote functions"
  location              = var.region
  max_time_travel_hours = "48"
}

data "google_iam_policy" "bigquery_dataset_functions" {
  binding {
    role = "roles/bigquery.dataEditor"
    members = [
      "projectWriters",
    ]
  }
  binding {
    role = "roles/bigquery.dataOwner"
    members = [
      "projectOwners",
    ]
  }
  binding {
    role = "roles/bigquery.dataViewer"
    members = concat(
      [
        "projectReaders",
        google_service_account.bigquery_scheduled_queries.member,
      ],
      var.bigquery_functions_data_viewer_members,
    )
  }
}

resource "google_bigquery_dataset_iam_policy" "functions" {
  dataset_id  = google_bigquery_dataset.functions.dataset_id
  policy_data = data.google_iam_policy.bigquery_dataset_functions.policy_data
}

resource "google_bigquery_routine" "libphonenumber_find_phone_numbers_in_text" {
  dataset_id   = google_bigquery_dataset.functions.dataset_id
  routine_id   = "libphonenumber_find_phone_numbers_in_text"
  routine_type = "SCALAR_FUNCTION"
  language     = "JAVASCRIPT"
  definition_body = templatefile(
    "bigquery/libphonenumber-find-phone-numbers-in-text.js",
    {
      project_id = var.project_id
    }
  )
  imported_libraries = [
    // From https://github.com/catamphetamine/libphonenumber-js
    "gs://${google_storage_bucket_object.libphonenumber.bucket}/${google_storage_bucket_object.libphonenumber.output_name}",
  ]
  return_type = jsonencode(
    {
      typeKind = "JSON"
    }
  )

  arguments {
    data_type = jsonencode(
      {
        typeKind = "STRING"
      }
    )
    name = "text"
  }
}

resource "google_bigquery_routine" "extract_phone_numbers" {
  dataset_id   = google_bigquery_dataset.functions.dataset_id
  routine_id   = "extract_phone_numbers"
  routine_type = "SCALAR_FUNCTION"
  language     = "SQL"
  definition_body = templatefile(
    "bigquery/extract-phone-numbers.sql",
    { project_id = var.project_id }
  )
  arguments {
    data_type = jsonencode(
      {
        typeKind = "STRING"
      }
    )
    name = "text"
  }
}

resource "google_bigquery_routine" "dedup" {
  dataset_id   = google_bigquery_dataset.functions.dataset_id
  routine_id   = "dedup"
  routine_type = "SCALAR_FUNCTION"
  language     = "SQL"
  definition_body = templatefile(
    "bigquery/dedup.sql",
    { project_id = var.project_id }
  )
  arguments {
    name          = "val"
    argument_kind = "ANY_TYPE"
  }
}

resource "google_bigquery_routine" "mask_pii" {
  dataset_id   = google_bigquery_dataset.functions.dataset_id
  routine_id   = "mask_pii"
  routine_type = "SCALAR_FUNCTION"
  language     = "SQL"
  definition_body = templatefile(
    "bigquery/mask-pii.sql",
    { project_id = var.project_id }
  )
  arguments {
    data_type = jsonencode(
      {
        typeKind = "STRING"
      }
    )
    name = "text"
  }
}

resource "google_bigquery_routine" "publishing_api_editions_current" {
  dataset_id      = google_bigquery_dataset.functions.dataset_id
  routine_id      = "publishing_api_editions_current"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = file("bigquery/publishing-api-editions-current.sql")
}

resource "google_bigquery_routine" "publishing_api_links_current" {
  dataset_id      = google_bigquery_dataset.functions.dataset_id
  routine_id      = "publishing_api_links_current"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = file("bigquery/publishing-api-links-current.sql")
}

resource "google_bigquery_routine" "publishing_api_unpublishings_current" {
  dataset_id      = google_bigquery_dataset.functions.dataset_id
  routine_id      = "publishing_api_unpublishings_current"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = file("bigquery/publishing-api-unpublishings-current.sql")
}

resource "google_bigquery_routine" "extract_content_from_editions" {
  dataset_id   = google_bigquery_dataset.functions.dataset_id
  routine_id   = "extract_content_from_editions"
  routine_type = "PROCEDURE"
  language     = "SQL"
  definition_body = templatefile(
    "bigquery/extract-content-from-editions.sql",
    { project_id = var.project_id, }
  )
}

resource "google_bigquery_routine" "assets" {
  dataset_id   = google_bigquery_dataset.functions.dataset_id
  routine_id   = "assets"
  routine_type = "PROCEDURE"
  language     = "SQL"
  definition_body = templatefile(
    "bigquery/assets.sql",
    { project_id = var.project_id, }
  )
}

# Must only be executed after
# google_bigquery_routine.extract_content_from_editions, which refreshes a table
# that this depends on.
resource "google_bigquery_routine" "base_path_lookup" {
  dataset_id   = google_bigquery_dataset.functions.dataset_id
  routine_id   = "base_path_lookup"
  routine_type = "PROCEDURE"
  language     = "SQL"
  definition_body = templatefile(
    "bigquery/base-path-lookup.sql",
    { project_id = var.project_id, }
  )
}

resource "google_bigquery_routine" "department_analytics_profile" {
  dataset_id   = google_bigquery_dataset.functions.dataset_id
  routine_id   = "department_analytics_profile"
  routine_type = "PROCEDURE"
  language     = "SQL"
  definition_body = templatefile(
    "bigquery/department-analytics-profile.sql",
    { project_id = var.project_id, }
  )
}

resource "google_bigquery_routine" "taxonomy" {
  dataset_id   = google_bigquery_dataset.functions.dataset_id
  routine_id   = "taxonomy"
  routine_type = "PROCEDURE"
  language     = "SQL"
  definition_body = templatefile(
    "bigquery/taxonomy.sql",
    { project_id = var.project_id }
  )
}

resource "google_bigquery_routine" "organisations" {
  dataset_id   = google_bigquery_dataset.functions.dataset_id
  routine_id   = "organisations"
  routine_type = "PROCEDURE"
  language     = "SQL"
  definition_body = templatefile(
    "bigquery/public-organisations.sql",
    { project_id = var.project_id }
  )
}

resource "google_bigquery_routine" "contact_phone_numbers" {
  dataset_id   = google_bigquery_dataset.functions.dataset_id
  routine_id   = "contact_phone_numbers"
  routine_type = "PROCEDURE"
  language     = "SQL"
  definition_body = templatefile(
    "bigquery/contact-phone-numbers.sql",
    { project_id = var.project_id }
  )
}

resource "google_bigquery_routine" "phone_numbers" {
  dataset_id   = google_bigquery_dataset.functions.dataset_id
  routine_id   = "phone_numbers"
  routine_type = "PROCEDURE"
  language     = "SQL"
  definition_body = templatefile(
    "bigquery/phone-numbers.sql",
    { project_id = var.project_id }
  )
}

resource "google_bigquery_routine" "start_button_links" {
  dataset_id      = google_bigquery_dataset.functions.dataset_id
  routine_id      = "start_button_links"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = file("bigquery/start-button-links.sql")
}

resource "google_bigquery_routine" "calc_oldest_allowable_freshness" {
  dataset_id      = google_bigquery_dataset.functions.dataset_id
  routine_id      = "calc_oldest_allowable_freshness"
  routine_type    = "SCALAR_FUNCTION"
  language        = "SQL"
  definition_body = file("bigquery/calc-oldest-allowable-freshness.sql")

  arguments {
    name      = "timestamp"
    data_type = "{\"typeKind\": \"TIMESTAMP\"}"
  }

  return_type = "{\"typeKind\": \"TIMESTAMP\"}"
}
