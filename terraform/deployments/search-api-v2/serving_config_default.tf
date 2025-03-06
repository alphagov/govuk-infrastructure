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
      filter = "content_purpose_supergroup: ANY(\"services\") OR document_type: ANY(\"calendar\", \"detailed_guide\", \"document_collection\", \"external_content\", \"organisation\")",
      boost  = 0.2
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
      filter = "document_type: ANY(\"guidance\", \"mainstream_browse_page\", \"policy_paper\", \"travel_advice\")",
      boost  = 0.05
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
      filter = "document_type: ANY(\"about\", \"taxon\", \"world_news_story\")",
      boost  = -0.25
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
      filter = "document_type: ANY(\"employment_tribunal_decision\", \"foi_release\", \"service_standard_report\") OR organisation_state: ANY(\"devolved\", \"closed\")",
      boost  = -0.5
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
      filter = "is_historic = 1",
      boost  = -0.75
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
      filter = "link: ANY(\"/government/publications/pension-credit-claim-form--2\")",
      boost  = -0.75
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
