output "private_subnets" {
  value = data.terraform_remote_state.infra_networking.outputs.private_subnet_ids
}

output "frontend_security_groups" {
  value       = module.frontend.security_groups
  description = "Used by ECS RunTask to run short-lived tasks with the same SG permissions as the frontend ECS Service."
}

output "content-store" {
  value = {
    draft = {
      task_definition_cli_input_json = module.draft_content_store.cli_input_json,
      network_config                 = module.draft_content_store.network_config
      signon_secrets = {
        bearer_tokens = [
          module.content_store_to_publishing_api_bearer_token.token_data,
          module.content_store_to_router_api_bearer_token.token_data,
        ],
        admin_password_arn = aws_secretsmanager_secret.signon_admin_password.arn,
        api_user_email     = local.signon_api_user.content_store,
        signon_api_url     = local.signon_api_url,
      }
    },
    live = {
      task_definition_cli_input_json = module.content_store.cli_input_json,
      network_config                 = module.content_store.network_config
      signon_secrets = {
        bearer_tokens = [
          module.draft_content_store_to_publishing_api_bearer_token.token_data,
          module.draft_content_store_to_router_api_bearer_token.token_data,
        ],
        admin_password_arn = aws_secretsmanager_secret.signon_admin_password.arn,
        api_user_email     = local.signon_api_user.content_store,
        signon_api_url     = local.signon_api_url,
      }
    },
  }
}

output "publisher" {
  value = {
    web = {
      task_definition_cli_input_json = module.publisher_web.cli_input_json,
      network_config                 = module.publisher_web.network_config
      signon_secrets = {
        bearer_tokens = [
          module.publisher_to_publishing_api_bearer_token.token_data,
        ],
        admin_password_arn = aws_secretsmanager_secret.signon_admin_password.arn,
        api_user_email     = local.signon_api_user.publisher,
        signon_api_url     = local.signon_api_url,
      }
    },
    worker = {
      task_definition_cli_input_json = module.publisher_worker.cli_input_json,
      network_config                 = module.publisher_worker.network_config
    },
  }
}

output "frontend" {
  value = {
    draft = {
      task_definition_cli_input_json = module.draft_frontend.cli_input_json,
      network_config                 = module.draft_frontend.network_config
    },
    live = {
      task_definition_cli_input_json = module.frontend.cli_input_json,
      network_config                 = module.frontend.network_config
      signon_secrets = {
        bearer_tokens = [
          module.frontend_to_publishing_api_bearer_token.token_data
        ],
        admin_password_arn = aws_secretsmanager_secret.signon_admin_password.arn,
        api_user_email     = local.signon_api_user.frontend,
        signon_api_url     = local.signon_api_url,
      }
    },
  }
}

output "publishing-api" {
  value = {
    web = {
      task_definition_cli_input_json = module.publishing_api_web.cli_input_json,
      network_config                 = module.publishing_api_web.network_config
      signon_secrets = {
        bearer_tokens = [
          module.publishing_api_to_router_api_bearer_token.token_data,
          module.publishing_api_to_draft_content_store_bearer_token.token_data,
          module.publishing_api_to_content_store_bearer_token.token_data,
        ],
        admin_password_arn = aws_secretsmanager_secret.signon_admin_password.arn,
        api_user_email     = local.signon_api_user.publishing_api,
        signon_api_url     = local.signon_api_url,
      }
    },
    worker = {
      task_definition_cli_input_json = module.publishing_api_worker.cli_input_json,
      network_config                 = module.publishing_api_worker.network_config
    },
  }
}

output "smokey" {
  value = {
    default = {
      task_definition_cli_input_json = module.smokey_task_definition.cli_input_json,
      network_config                 = module.smokey_network_config.network_config
    }
  }
}

output "log_group" {
  value = local.log_group
}

output "mesh_name" {
  value = aws_appmesh_mesh.govuk.name
}

output "mesh_domain" {
  value = local.mesh_domain
}

output "external_app_domain" {
  value = local.workspace_external_domain
}

output "internal_app_domain" {
  value = var.internal_app_domain
}

output "govuk_website_root" {
  value = "https://frontend.${local.workspace_external_domain}" # TODO: Change back to www once router is up
}

output "fargate_execution_iam_role_arn" {
  value = aws_iam_role.execution.arn
}

output "fargate_task_iam_role_arn" {
  value = aws_iam_role.task.arn
}

output "signon" {
  value = {
    web = {
      task_definition_cli_input_json = module.signon.cli_input_json,
      network_config                 = module.signon.network_config
    }
  }
}

output "signon_bootstrap_command" {
  # TODO: Make publishing_service_domain workspace-aware once OAuth applications done
  value = "bundle exec rake bootstrap:all[${var.publishing_service_domain}${local.is_default_workspace ? "" : ",${terraform.workspace}"}]"
}

output "static" {
  value = {
    draft = {
      task_definition_cli_input_json = module.draft_static.cli_input_json,
      network_config                 = module.draft_static.network_config
    },
    live = {
      task_definition_cli_input_json = module.static.cli_input_json,
      network_config                 = module.static.network_config
    },
  }
}

output "router-api" {
  value = {
    draft = {
      task_definition_cli_input_json = module.draft_router_api.cli_input_json,
      network_config                 = module.draft_router_api.network_config
    },
    live = {
      task_definition_cli_input_json = module.router_api.cli_input_json,
      network_config                 = module.router_api.network_config
    },
  }
}

output "router" {
  value = {
    draft = {
      task_definition_cli_input_json = module.draft_router.cli_input_json,
      network_config                 = module.draft_router.network_config
    },
    live = {
      task_definition_cli_input_json = module.router.cli_input_json,
      network_config                 = module.router.network_config
    },
  }
}

output "authenticating-proxy" {
  value = {
    web = {
      task_definition_cli_input_json = module.authenticating_proxy.cli_input_json,
      network_config                 = module.authenticating_proxy.network_config
    }
  }
}

output "cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "dns_public_zone_id" {
  value = aws_route53_zone.workspace_public.zone_id
}

output "public_certificate_arn" {
  value = aws_acm_certificate.workspace_public.arn
}
