apps_namespace = "apps"
licensify_namespace = "licsensify"
datagovuk_namespace = "datagovuk"
argo_workflows_namespaces = ["apps"]
ship_kubernetes_events_to_logit = false
dex_github_orgs_teams = [{
  name  = "alphagov"
  teams = ["gov-uk", "gov-uk-production-deploy", "gov-uk-ithc-and-penetration-testing"]
}]

force_destroy = true
