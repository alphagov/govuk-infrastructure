locals {
  oauth_applications = [
    for name, v in local.signon_app : module.oauth_applications[name].app_data
  ]

  app_workspace_prefix = local.is_default_workspace ? "" : "[${terraform.workspace}] "

  signon_app = {
    authenticating_proxy = {
      name          = "${local.app_workspace_prefix}Content Preview"
      description   = "Draft version of GOV.UK"
      shortname     = "content_preview"
      subdomain     = "draft-origin"
      permissions   = []
      redirect_path = "/auth/gds/callback"
    }
    content_store = {
      name          = "${local.app_workspace_prefix}Content Store"
      description   = "Central store for live content on GOV.UK"
      shortname     = "content_store"
      subdomain     = "content-store"
      permissions   = []
      redirect_path = "/auth/gds/callback"
    }
    draft_content_store = {
      name          = "${local.app_workspace_prefix}Draft Content Store"
      description   = "Central store for draft content on GOV.UK"
      shortname     = "draft_content_store"
      subdomain     = "draft-content-store"
      permissions   = []
      redirect_path = "/auth/gds/callback"
    }
    publisher = {
      name        = "${local.app_workspace_prefix}Publisher"
      description = "Publish mainstream content"
      shortname   = "publisher"
      subdomain   = "publisher"
      permissions = [
        "govuk_editor",
        "skip_review",
        "welsh_editor"
      ]
      redirect_path = "/auth/gds/callback"
    }
    publishing_api = {
      name          = "${local.app_workspace_prefix}Publishing API"
      description   = "Central store for all publishing content on GOV.UK"
      shortname     = "pub_api"
      subdomain     = "publishing-api"
      permissions   = ["view_all"]
      redirect_path = "/auth/gds/callback"
    }
    router_api = {
      name          = "${local.app_workspace_prefix}Router API"
      description   = "Manages the router database"
      shortname     = "router_api"
      subdomain     = "router-api"
      permissions   = []
      redirect_path = "/auth/gds/callback"
    }
    draft_router_api = {
      name          = "${local.app_workspace_prefix}Draft Router API"
      description   = "Manages the router database"
      shortname     = "draft_router_api"
      subdomain     = "draft-router-api"
      permissions   = []
      redirect_path = "/auth/gds/callback"
    }
  }
}

module "oauth_applications" {
  source   = "../../modules/signon_oauth_application"
  for_each = local.signon_app

  additional_tags = local.additional_tags
  app_name        = each.value.name
  description     = each.value.description
  environment     = var.govuk_environment
  # TODO Change this to local.public_domain once publishing.service domains
  # for backend apps are working.
  home_uri      = "https://${each.value.subdomain}.${local.workspace_external_domain}"
  permissions   = each.value.permissions
  app_shortname = each.value.shortname
  redirect_path = each.value.redirect_path
  workspace     = local.workspace
}
