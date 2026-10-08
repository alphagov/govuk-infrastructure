module "serving_config_global_variant" {
  source = "./modules/serving_config"

  id           = "variant"
  display_name = "Variant (used as the 'B' variant when AB testing live Search API v2)"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id

  boost_control_ids = [
    # identical to serving_config_global_default
    module.control_global_boost_promote_medium.id,
    module.control_global_boost_promote_low.id,
    module.control_global_boost_demote_low.id,
    module.control_global_boost_demote_low_pages.id,
    module.control_global_boost_demote_medium.id,
    module.control_global_boost_demote_pages.id,
    module.control_global_boost_demote_strong.id,
  ]
  filter_control_ids = [
    # identical to serving_config_global_default
    module.control_global_filter_temporary_exclusions.id,
  ]
  synonyms_control_ids = [
    # identical to serving_config_global_default
    module.control_global_synonym_hmrc.id,
    # unique to serving_config_global_variant
    module.control_global_synonym_news.id,
    module.control_global_synonym_news.id,
    module.control_global_synonym_dcms.id,
    module.control_global_synonym_euss.id,
    module.control_global_synonym_id.id,
    module.control_global_synonym_chat.id,
    module.control_global_synonym_ni.id,
    module.control_global_synonym_nic.id,
    module.control_global_synonym_nin.id,
    module.control_global_synonym_poa.id,
    module.control_global_synonym_reg.id,
    module.control_global_synonym_share_code.id,
    module.control_global_synonym_uc.id,
  ]
}

module "control_global_synonym_news" {
  source = "./modules/control"

  id           = "syn_news"
  display_name = "Synonyms: news"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id
  action = {
    synonymsAction = {
      synonyms = [
        "announcements",
        "news",
        "statistics",
      ]
    }
  }
}

module "control_global_synonym_cos" {
  source = "./modules/control"

  id           = "syn_cos"
  display_name = "Synonyms: COS"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id
  action = {
    synonymsAction = {
      synonyms = [
        "cos",
        "certificate of sponsorship",
        "certificates of sponsorship",
      ]
    }
  }
}

module "control_global_synonym_dcms" {
  source = "./modules/control"

  id           = "syn_dcms"
  display_name = "Synonyms: DCMS"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id
  action = {
    synonymsAction = {
      synonyms = [
        "dcms",
        "department for digital culture media and sport",
      ]
    }
  }
}

module "control_global_synonym_euss" {
  source = "./modules/control"

  id           = "syn_euss"
  display_name = "Synonyms: EUSS"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id
  action = {
    synonymsAction = {
      synonyms = [
        "euss",
        "eu settlement scheme",
      ]
    }
  }
}

module "control_global_synonym_id" {
  source = "./modules/control"

  id           = "syn_id"
  display_name = "Synonyms: id"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id
  action = {
    synonymsAction = {
      synonyms = [
        "i'd",
        "i’d",
        "id"
      ]
    }
  }
}

module "control_global_synonym_chat" {
  source = "./modules/control"

  id           = "syn_chat"
  display_name = "Synonyms: chat"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id
  action = {
    synonymsAction = {
      synonyms = [
        "live chat",
        "webchat",
        "web chat",
        "online chat",
        "contact"
      ]
    }
  }
}

module "control_global_synonym_ni" {
  source = "./modules/control"

  id           = "syn_ni"
  display_name = "Synonyms: NI"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id
  action = {
    synonymsAction = {
      synonyms = [
        "ni",
        "national insurance"
      ]
    }
  }
}

module "control_global_synonym_nic" {
  source = "./modules/control"

  id           = "syn_nic"
  display_name = "Synonyms: NIC"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id
  action = {
    synonymsAction = {
      synonyms = [
        "nic",
        "nics",
        "national insurance contributions"
      ]
    }
  }
}

module "control_global_synonym_nin" {
  source = "./modules/control"

  id           = "syn_nin"
  display_name = "Synonyms: NIN"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id
  action = {
    synonymsAction = {
      synonyms = [
        "nin",
        "nino",
        "national insurance number"
      ]
    }
  }
}

module "control_global_synonym_poa" {
  source = "./modules/control"

  id           = "syn_poa"
  display_name = "Synonyms: POA"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id
  action = {
    synonymsAction = {
      synonyms = [
        "poa",
        "power of attorney",
      ]
    }
  }
}

module "control_global_synonym_reg" {
  source = "./modules/control"

  id           = "syn_reg"
  display_name = "Synonyms: reg"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id
  action = {
    synonymsAction = {
      synonyms = [
        "reg",
        "registration",
      ]
    }
  }
}

module "control_global_synonym_share_code" {
  source = "./modules/control"

  id           = "syn_share_code"
  display_name = "Synonyms: share code"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id
  action = {
    synonymsAction = {
      synonyms = [
        "shercod",
        "share code",
      ]
    }
  }
}

module "control_global_synonym_uc" {
  source = "./modules/control"

  id           = "syn_uc"
  display_name = "Synonyms: UC"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id
  action = {
    synonymsAction = {
      synonyms = [
        "uc",
        "universal credit",
      ]
    }
  }
}