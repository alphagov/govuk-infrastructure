# Service account for the service
resource "google_service_account" "govgraphsearch" {
  account_id   = "govgraphsearch"
  display_name = "GovGraph Search"
  description  = "Service account for the GovGraph search Cloud Run app"
}

# Service account for deploying the app
resource "google_service_account" "govgraphsearch_deploy" {
  account_id   = "service-acc-govsearch-ci-cd"
  display_name = "GovGraph Search CI/CD"
  description  = "Service account used by the GovSearch application's Continuous Integration/Continuous Deployment pipeline"
}

data "google_iam_policy" "govgraphsearch_service_account" {
  binding {
    role = "roles/iam.serviceAccountUser"
    members = [
      google_service_account.govgraphsearch_deploy.member,
    ]
  }
}

resource "google_service_account_iam_policy" "govgraphsearch" {
  service_account_id = google_service_account.govgraphsearch.name
  policy_data        = data.google_iam_policy.govgraphsearch_service_account.policy_data
}

# Create this first, on its own: The IAP OAuth consent screen (Identity-Aware
# Proxy)
resource "google_iap_brand" "project_brand" {
  # The support_email must be your own email address, or a Google Group that you
  # manage.
  support_email     = "govgraph-developers@digital.cabinet-office.gov.uk"
  application_title = var.application_title
}

# Then manually create OAUTH credentials:
# https://console.cloud.google.com/apis/credentials/oauthclient

# Add a redirect URI of the form
# https://iap.googleapis.com/v1/oauth/clientIds/CLIENT_ID:handleRedirect

# Then create the secrets in Secret Manager
# https://blog.gruntwork.io/a-comprehensive-guide-to-managing-secrets-in-your-terraform-code-1d586955ace1#bebe
resource "google_secret_manager_secret" "iap_oauth_client_id" {
  secret_id = "iap-oauth-client-id"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "iap_oauth_client_secret" {
  secret_id = "iap-oauth-client-secret"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "sso_oauth_client_id" {
  secret_id = "OAUTH_ID"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "sso_oauth_client_secret" {
  secret_id = "OAUTH_SECRET"
  replication {
    auto {}
  }
}

# Create a secret for cookie signing
resource "google_secret_manager_secret" "cookie-session-signature" {
  secret_id = "cookie-session-signature"
  replication {
    auto {}
  }
}

# Allow the Cloud Run service to access the GOV.UK Signon secrets
data "google_iam_policy" "sso_oauth_client_id" {
  binding {
    role = "roles/secretmanager.secretAccessor"
    members = [
      google_service_account.govgraphsearch.member,
    ]
  }
}

resource "google_secret_manager_secret_iam_policy" "sso_oauth_client_id" {
  secret_id   = google_secret_manager_secret.sso_oauth_client_id.secret_id
  policy_data = data.google_iam_policy.sso_oauth_client_id.policy_data
}

data "google_iam_policy" "sso_oauth_client_secret" {
  binding {
    role = "roles/secretmanager.secretAccessor"
    members = [
      google_service_account.govgraphsearch.member,
    ]
  }
}

resource "google_secret_manager_secret_iam_policy" "sso_oauth_client_secret" {
  secret_id   = google_secret_manager_secret.sso_oauth_client_secret.secret_id
  policy_data = data.google_iam_policy.sso_oauth_client_secret.policy_data
}

data "google_iam_policy" "cookie-session-signature" {
  binding {
    role = "roles/secretmanager.secretAccessor"
    members = [
      google_service_account.govgraphsearch.member,
    ]
  }
}

resource "google_secret_manager_secret_iam_policy" "cookie-session-signature" {
  secret_id   = google_secret_manager_secret.cookie-session-signature.secret_id
  policy_data = data.google_iam_policy.cookie-session-signature.policy_data
}

# Then manually paste the OAUTH credentials into the Secret Manager

# Then create a place to put the app images
resource "google_artifact_registry_repository" "cloud_run_source_deploy" {
  description            = "Cloud Run Source Deployments"
  format                 = "DOCKER"
  location               = var.region
  repository_id          = "cloud-run-source-deploy"
  cleanup_policy_dry_run = false
  cleanup_policies {
    # Is overridden by a KEEP policy
    id     = "delete-old-versions"
    action = "DELETE"
    condition {
      older_than = "2678400s" # 31 days
    }
  }
  cleanup_policies {
    # Overrides a DELETE policy
    id     = "keep-a-number-of-recent-versions"
    action = "KEEP"
    most_recent_versions {
      keep_count = 1
    }
  }
}

data "google_iam_policy" "artifact_registry_cloud_run_source_deploy" {
  binding {
    role = "roles/artifactregistry.writer"
    members = [
      google_service_account.govgraphsearch_deploy.member,
    ]
  }
}

resource "google_artifact_registry_repository_iam_policy" "cloud_run_source_deploy" {
  project     = google_artifact_registry_repository.cloud_run_source_deploy.project
  location    = google_artifact_registry_repository.cloud_run_source_deploy.location
  repository  = google_artifact_registry_repository.cloud_run_source_deploy.name
  policy_data = data.google_iam_policy.artifact_registry_cloud_run_source_deploy.policy_data
}

# Then push a docker image to that place.

# Then create DNS zones
resource "google_dns_managed_zone" "govgraphsearch" {
  name        = "govgraphsearch"
  description = "DNS zone for govgraphsearch domain"
  dns_name    = "${var.govgraphsearch_domain}."
}

# Then manually buy a domain in Cloud Domains and link it to this zone.

# Then create everything else below.

# Retrieve the value of the secret
data "google_secret_manager_secret_version" "iap_oauth_client_id" {
  secret = "iap-oauth-client-id"
}

data "google_secret_manager_secret_version" "iap_oauth_client_secret" {
  secret = "iap-oauth-client-secret"
}

data "google_secret_manager_secret_version" "sso_oauth_client_id" {
  secret = "OAUTH_ID"
}

data "google_secret_manager_secret_version" "sso_oauth_client_secret" {
  secret = "OAUTH_SECRET"
}

data "google_secret_manager_secret_version" "cookie-session-signature" {
  secret = "cookie-session-signature"
}

# Boilerplate
resource "google_compute_region_network_endpoint_group" "govgraphsearch_eg" {
  name   = "govgraphsearch-eg"
  region = var.region
  cloud_run {
    service = google_cloud_run_service.govgraphsearch.name
  }
}

# Connect to the VPC
resource "google_vpc_access_connector" "cloudrun_connector" {
  name = "cloudrun-connector"
  subnet {
    name = "cloudrun-subnet"
  }
}

# Allow access the app via IAP (Identity-Aware Proxy)
data "google_iam_policy" "govgraphsearch_iap" {
  binding {
    role    = "roles/iap.httpsResourceAccessor"
    members = var.iap_govgraphsearch_members
  }
}

resource "google_iap_web_backend_service_iam_policy" "govgraphsearch" {
  web_backend_service = google_compute_backend_service.govgraphsearch.name
  policy_data         = data.google_iam_policy.govgraphsearch_iap.policy_data
}

# Allow anyone who has already been through IAP or GOV.UK Signon to load the app
data "google_iam_policy" "govgraphsearch" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "govgraphsearch" {
  location    = var.region
  service     = google_cloud_run_service.govgraphsearch.name
  policy_data = data.google_iam_policy.govgraphsearch.policy_data
}

# The app itself
resource "google_cloud_run_service" "govgraphsearch" {
  name     = "govuk-knowledge-graph-search"
  location = var.region
  # https://github.com/hashicorp/terraform-provider-google/issues/9438#issuecomment-871946786
  autogenerate_revision_name = true
  metadata {
    annotations = {
      # The ingress setting can only be set when the cloudrun service already
      # exists.
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
    }
  }
  template {
    metadata {
      annotations = {
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.cloudrun_connector.self_link
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
      }
    }
    spec {
      service_account_name = google_service_account.govgraphsearch.email
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.cloud_run_source_deploy.repository_id}/govuk-knowledge-graph-search:latest"
        env {
          name  = "GTM_ID"
          value = var.gtm_id
        }
        env {
          name  = "GTM_AUTH"
          value = var.gtm_auth
        }
        env {
          name  = "REDIS_HOST"
          value = try(google_redis_instance.session_store[0].host, "")
        }
        env {
          name  = "REDIS_PORT"
          value = try(google_redis_instance.session_store[0].port, "")
        }
        env {
          name  = "NODE_ENV"
          value = var.environment
        }
        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }
        env {
          name  = "ENABLE_AUTH"
          value = var.enable_auth
        }
        env {
          name  = "SIGNON_URL"
          value = var.signon_url
        }
        env {
          name  = "OAUTH_AUTH_URL"
          value = var.oauth_auth_url
        }
        env {
          name  = "OAUTH_TOKEN_URL"
          value = var.oauth_token_url
        }
        env {
          name  = "OAUTH_CALLBACK_URL"
          value = var.oauth_callback_url
        }
        env {
          name = "OAUTH_ID"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = "OAUTH_ID"
            }
          }
        }
        env {
          name = "OAUTH_SECRET"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = "OAUTH_SECRET"
            }
          }
        }
        env {
          name = "cookie-session-signature"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = "cookie-session-signature"
            }
          }
        }
      }
    }
  }
}

# We could use a lovely, convenient, official Google terraform module, which
# would create a lot of terraform for us behind the scenes, but unfortunately it
# forces downtime when adding/removing certificates for domains.
# https://cloud.google.com/blog/topics/developers-practitioners/new-terraform-module-serverless-load-balancing
# https://github.com/terraform-google-modules/terraform-google-lb-http/issues/241

resource "google_compute_backend_service" "govgraphsearch" {
  name      = "govgraphsearch-backend-govgraphsearch"
  port_name = "http"
  protocol  = "HTTP"
  backend {
    group = google_compute_region_network_endpoint_group.govgraphsearch_eg.self_link
  }
  iap {
    enabled              = var.enable_auth
    oauth2_client_id     = data.google_secret_manager_secret_version.iap_oauth_client_id.secret_data
    oauth2_client_secret = data.google_secret_manager_secret_version.iap_oauth_client_secret.secret_data
  }
}

resource "google_compute_global_address" "govgraphsearch" {
  name = "govgraphsearch-address"
}

resource "google_compute_global_forwarding_rule" "govgraphsearch_http" {
  name       = "govgraphsearch"
  port_range = "80"
  ip_address = google_compute_global_address.govgraphsearch.address
  target     = google_compute_target_http_proxy.govgraphsearch.self_link
}

resource "google_dns_managed_zone" "govsearch" {
  name        = "gov-search-zone"
  description = "The zone for the gov-search service domain"
  dns_name    = "${var.govsearch_domain}."
}

resource "google_dns_record_set" "govsearch" {
  name         = google_dns_managed_zone.govsearch.dns_name
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.govsearch.name
  rrdatas      = [google_compute_global_address.govgraphsearch.address]
}

resource "google_compute_managed_ssl_certificate" "govsearch" {
  name        = "govsearch-cert"
  description = "The SSL certificate of the GovSearch service domain"
  managed {
    domains = [
      var.govsearch_domain,
    ]
  }
}

resource "google_compute_target_https_proxy" "govgraphsearch" {
  name = "govgraphsearch-https-proxy"
  ssl_certificates = [
    google_compute_managed_ssl_certificate.govgraphsearch.self_link,
    google_compute_managed_ssl_certificate.govsearch.self_link,
  ]
  url_map = google_compute_url_map.govgraphsearch.self_link
}

resource "google_compute_global_forwarding_rule" "govgraphsearch_https" {
  name       = "govgraphsearch-https"
  port_range = "443"
  ip_address = google_compute_global_address.govgraphsearch.address
  target     = google_compute_target_https_proxy.govgraphsearch.self_link
}

resource "google_compute_managed_ssl_certificate" "govgraphsearch" {
  name = "govgraphsearch-cert"
  managed {
    domains = [
      var.govgraphsearch_domain,
    ]
  }
}

resource "google_compute_target_http_proxy" "govgraphsearch" {
  name    = "govgraphsearch-http-proxy"
  url_map = google_compute_url_map.govgraphsearch_https_redirect.self_link
}

resource "google_compute_url_map" "govgraphsearch" {
  default_service = google_compute_backend_service.govgraphsearch.self_link
  name            = "govgraphsearch-url-map"
}

resource "google_compute_url_map" "govgraphsearch_https_redirect" {
  name = "govgraphsearch-https-redirect"
  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    https_redirect         = true
    strip_query            = false
  }
}

# Direct DNS to the IP address of the frontends of the load balancers
resource "google_dns_record_set" "govgraphsearch" {
  name         = google_dns_managed_zone.govgraphsearch.dns_name
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.govgraphsearch.name
  rrdatas      = [google_compute_global_address.govgraphsearch.address]
}
