module "serving_config_default" {
  source = "./modules/serving_config"

  id           = "default_search"
  display_name = "Default (used by live Search API v2)"
  engine_id    = google_discovery_engine_search_engine.govuk.engine_id

  boost_control_ids = [
    module.control_boost_demote_low.id,
    module.control_boost_demote_medium.id,
    module.control_boost_demote_pages.id,
    module.control_boost_demote_strong.id,
    module.control_boost_promote_low.id,
    module.control_boost_promote_medium.id,
  ]
  filter_control_ids = [
    module.control_filter_temporary_exclusions.id,
  ]
  synonyms_control_ids = [
    module.control_synonym_hmrc.id,
  ]
}

module "control_boost_promote_medium" {
  source = "./modules/control"

  id           = "boost_promote_medium"
  display_name = "Boost: Promote medium"
  engine_id    = google_discovery_engine_search_engine.govuk.engine_id
  action = {
    boostAction = {
      filter     = "content_purpose_supergroup: ANY(\"services\") OR document_type: ANY(\"calendar\", \"detailed_guide\", \"document_collection\", \"external_content\", \"organisation\")",
      fixedBoost = 0.2
      dataStore  = google_discovery_engine_data_store.govuk_content.name
    }
  }
}

module "control_boost_promote_low" {
  source = "./modules/control"

  id           = "boost_promote_low"
  display_name = "Boost: Promote low"
  engine_id    = google_discovery_engine_search_engine.govuk.engine_id
  action = {
    boostAction = {
      filter     = "document_type: ANY(\"guidance\", \"mainstream_browse_page\", \"policy_paper\", \"travel_advice\")",
      fixedBoost = 0.05
      dataStore  = google_discovery_engine_data_store.govuk_content.name
    }
  }
}

module "control_boost_demote_low" {
  source = "./modules/control"

  id           = "boost_demote_low"
  display_name = "Boost: Demote low"
  engine_id    = google_discovery_engine_search_engine.govuk.engine_id
  action = {
    boostAction = {
      filter     = "document_type: ANY(\"about\", \"taxon\", \"world_news_story\")",
      fixedBoost = -0.25
      dataStore  = google_discovery_engine_data_store.govuk_content.name
    }
  }
}

module "control_boost_demote_medium" {
  source = "./modules/control"

  id           = "boost_demote_medium"
  display_name = "Boost: Demote medium"
  engine_id    = google_discovery_engine_search_engine.govuk.engine_id
  action = {
    boostAction = {
      filter     = "document_type: ANY(\"employment_tribunal_decision\", \"foi_release\", \"service_standard_report\") OR organisation_state: ANY(\"devolved\", \"closed\")",
      fixedBoost = -0.5
      dataStore  = google_discovery_engine_data_store.govuk_content.name
    }
  }
}

module "control_boost_demote_strong" {
  source = "./modules/control"

  id           = "boost_demote_strong"
  display_name = "Boost: Demote strong"
  engine_id    = google_discovery_engine_search_engine.govuk.engine_id
  action = {
    boostAction = {
      filter     = "is_historic = 1",
      fixedBoost = -0.75
      dataStore  = google_discovery_engine_data_store.govuk_content.name
    }
  }
}

module "control_boost_demote_pages" {
  source = "./modules/control"

  id           = "boost_demote_pages"
  display_name = "Boost: Demote specific pages"
  engine_id    = google_discovery_engine_search_engine.govuk.engine_id
  action = {
    boostAction = {
      filter     = "link: ANY(\"/government/publications/pension-credit-claim-form--2\")",
      fixedBoost = -0.75
      dataStore  = google_discovery_engine_data_store.govuk_content.name
    }
  }
}

locals {
  # Pages to temporarily exclude from search results
  filtered_pages = [
    # GOV.UK app beta
    "/government/publications/govuk-app-terms-and-conditions",
    "/government/publications/govuk-app-privacy-notice-how-we-use-your-data",
    "/government/publications/govuk-app-test-privacy-notice-how-we-use-your-data",
    "/government/publications/accessibility-statement-for-the-govuk-app",
    "/sign-up-test-govuk-app",
    "/contact/govuk-app-support",
  ]
  filtered_pages_expr = join(",", [for page in local.filtered_pages : "\"${page}\""])
}
module "control_filter_temporary_exclusions" {
  source = "./modules/control"

  id           = "filter_temporary_exclusions"
  display_name = "Filter: Temporary exclusions"
  engine_id    = google_discovery_engine_search_engine.govuk.engine_id

  action = {
    filterAction = {
      filter    = "NOT link: ANY(${local.filtered_pages_expr})"
      dataStore = google_discovery_engine_data_store.govuk_content.name
    }
  }
}

module "control_synonym_hmrc" {
  source = "./modules/control"

  id           = "syn_hmrc"
  display_name = "Synonyms: HMRC"
  engine_id    = google_discovery_engine_search_engine.govuk.engine_id
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
