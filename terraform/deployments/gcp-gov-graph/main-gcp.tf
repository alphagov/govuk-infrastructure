# Adapted from https://medium.com/rockedscience/how-to-fully-automate-the-deployment-of-google-cloud-platform-projects-with-terraform-16c33f1fb31f

# ========================================================
# Create Google Cloud Projects from scratch with Terraform
# ========================================================
#
# This script is a workaround to fix an issue with the
# Google Cloud Platform API that prevents to fully
# automate the deployment of a project _from scratch_
# with Terraform, as described here:
# https://stackoverflow.com/questions/68308103/gcp-project-creation-via-api-doesnt-enable-service-usage-api
# It uses the `gcloud` CLI:
# https://cloud.google.com/sdk/gcloud
# in the pipeline. The `gcloud` CLI therefore needs to be
# installed and provided with sufficient credentials to
# consume the API.
# Full article:
# https://medium.com/rockedscience/how-to-fully-automate-the-deployment-of-google-cloud-platform-projects-with-terraform-16c33f1fb31f

# Set variables to reuse them across the resources
# and enforce consistency.
variable "environment" {
  type = string
}

variable "project_id" {
  type = string
}

variable "project_number" {
  type = string
}

variable "billing_account" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

# Google Cloud Storage location https://cloud.google.com/storage/docs/locations
variable "location" {
  type = string
}

variable "govgraph_domain" {
  type = string
}

variable "govgraphsearch_domain" {
  type = string
}

variable "govsearch_domain" {
  type = string
}

variable "application_title" {
  type = string
}

variable "enable_auth" {
  type = string
}

variable "signon_url" {
  type = string
}

variable "oauth_auth_url" {
  type = string
}

variable "oauth_token_url" {
  type = string
}

variable "oauth_callback_url" {
  type = string
}

variable "iap_govgraphsearch_members" {
  type = set(string)
}

variable "services" {
  type = list(any)
}

variable "postgres-startup-script" {
  type = string
}

variable "alerts_error_message_old_data" {
  type = string
}

variable "alerts_error_message_no_data" {
  type = string
}

variable "enable_redis_session_store_instance" {
  type = bool
}

variable "gtm_id" {
  type = string
}

variable "gtm_auth" {
  type = string
}

variable "project_owner_members" {
  type = list(string)
}

variable "bigquery_job_user_members" {
  type = list(string)
}

variable "storage_data_processed_object_viewer_members" {
  type = list(string)
}

variable "bigquery_content_data_viewer_members" {
  type = list(string)
}

variable "bigquery_publisher_data_viewer_members" {
  type = list(string)
}

variable "bigquery_functions_data_viewer_members" {
  type = list(string)
}

variable "bigquery_graph_data_viewer_members" {
  type = list(string)
}

variable "bigquery_private_data_viewer_members" {
  type = list(string)
}

variable "bigquery_public_data_viewer_members" {
  type = list(string)
}

variable "bigquery_publishing_api_data_viewer_members" {
  type = list(string)
}

variable "bigquery_smart_survey_data_viewer_members" {
  type = list(string)
}

variable "bigquery_support_api_data_viewer_members" {
  type = list(string)
}

variable "bigquery_search_data_viewer_members" {
  type = list(string)
}

variable "bigquery_test_data_viewer_members" {
  type = list(string)
}

variable "bigquery_whitehall_data_viewer_members" {
  type = list(string)
}

variable "bigquery_asset_manager_data_viewer_members" {
  type = list(string)
}

variable "bigquery_zendesk_data_viewer_members" {
  type = list(string)
}

terraform {
  required_providers {
    google = {
      version = "6.27.0" # Pinning the version required by terraform-google-modules/container-vm/google.
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone

  # Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#user_project_override
  user_project_override = true
  billing_project       = var.project_id
}

# Create the project
resource "google_project" "project" {
  billing_account = var.billing_account # Uncomment once known
  folder_id       = var.folder_id
  name            = var.project_id
  project_id      = var.project_id
  labels = {
    # The value can only contain lowercase letters, numeric characters,
    # underscores and dashes. The value can be at most 63 characters long.
    # International characters are allowed.
    programme = "govuk",
    team      = "govuk-data-engineering",
  }
  lifecycle {
    prevent_destroy = true
  }
}

# Use `gcloud` to enable:
# - serviceusage.googleapis.com
# - cloudresourcemanager.googleapis.com
resource "null_resource" "enable_service_usage_api" {
  provisioner "local-exec" {
    command = "gcloud services enable serviceusage.googleapis.com cloudresourcemanager.googleapis.com --project ${var.project_id}"
  }

  depends_on = [google_project.project]
}

# Enable other services used in the project
resource "google_project_service" "services" {
  for_each = toset(var.services)

  project                    = var.project_id
  service                    = each.key
  disable_dependent_services = false
  disable_on_destroy         = false

}

resource "google_compute_project_default_network_tier" "default" {
  # Premium for static global IP addresses.  Can be overridden by specific
  # instances that don't require those.
  network_tier = "PREMIUM"
}

resource "google_project_iam_policy" "project" {
  project     = var.project_id
  policy_data = data.google_iam_policy.project.policy_data
}

# All IAM members at the project level must be given here.
#
# If terraform is about to remove the permissions of a default service account,
# then that is probably because Google automatically created the account since
# this file was last updated. In that case, add the new permissions here and
# check the terraform plan again.
data "google_iam_policy" "project" {
  binding {
    role = "roles/owner"
    members = concat(
      [
      ],
      var.project_owner_members,
    )
  }

  binding {
    role = "roles/editor"
    members = [
      "serviceAccount:${var.project_number}@cloudservices.gserviceaccount.com",
      "serviceAccount:${var.project_id}@appspot.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/appengine.serviceAgent"
    members = [
      "serviceAccount:service-${var.project_number}@gcp-gae-service.iam.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/artifactregistry.admin"
    members = [
      google_service_account.govgraphsearch_deploy.member,
    ]
  }

  binding {
    role = "roles/artifactregistry.serviceAgent"
    members = [
      "serviceAccount:service-${var.project_number}@gcp-sa-artifactregistry.iam.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/bigquery.jobUser"
    members = concat(
      [
        google_service_account.bigquery_page_views.member,
        google_service_account.bigquery_scheduled_queries.member,
        google_service_account.bigquery_scheduled_queries_search.member,
        google_service_account.gce_publishing_api.member,
        google_service_account.gce_support_api.member,
        google_service_account.gce_publisher.member,
        google_service_account.gce_whitehall.member,
        google_service_account.gce_asset_manager.member,
        google_service_account.govgraphsearch.member,
        google_service_account.workflow_smart_survey.member,
        google_service_account.workflow_zendesk.member,
      ],
      var.bigquery_job_user_members
    )
  }

  binding {
    role = "roles/bigquerydatatransfer.serviceAgent"
    members = [
      "serviceAccount:service-${var.project_number}@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com",
    ]
  }

  # For exporting everything as terraform
  binding {
    role = "roles/cloudasset.serviceAgent"
    members = [
      "serviceAccount:service-${var.project_number}@gcp-sa-cloudasset.iam.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/cloudasset.serviceAgent"
    members = [
      "serviceAccount:service-${var.project_number}@gcp-sa-cloudasset.iam.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/cloudbuild.builds.builder"
    members = [
      "serviceAccount:${var.project_number}@cloudbuild.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/cloudbuild.builds.editor"
    members = [
      google_service_account.govgraphsearch_deploy.member,
    ]
  }

  binding {
    role = "roles/cloudbuild.serviceAgent"
    members = [
      "serviceAccount:service-${var.project_number}@gcp-sa-cloudbuild.iam.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/cloudscheduler.serviceAgent"
    members = [
      "serviceAccount:service-${var.project_number}@gcp-sa-cloudscheduler.iam.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/cloudfunctions.serviceAgent"
    members = [
      "serviceAccount:service-${var.project_number}@gcf-admin-robot.iam.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/compute.instanceAdmin.v1"
    members = [
      google_service_account.gce_publishing_api.member,
      google_service_account.gce_support_api.member,
      google_service_account.gce_publisher.member,
      google_service_account.gce_whitehall.member,
      google_service_account.gce_asset_manager.member,
      google_service_account.workflow_govuk_database_backups.member,
      google_service_account.workflow_redis_cli.member
    ]
  }

  binding {
    role = "roles/compute.serviceAgent"
    members = [
      "serviceAccount:service-${var.project_number}@compute-system.iam.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/containerregistry.ServiceAgent"
    members = [
      "serviceAccount:service-${var.project_number}@containerregistry.iam.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/dlp.user"
    members = [
      google_service_account.data_loss_prevention.member,
    ]
  }

  binding {
    members = [
      "serviceAccount:service-${var.project_number}@gcp-sa-eventarc.iam.gserviceaccount.com",
    ]
    role = "roles/eventarc.serviceAgent"
  }

  binding {
    role = "roles/firestore.serviceAgent"
    members = [
      "serviceAccount:service-${var.project_number}@gcp-sa-firestore.iam.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/iam.serviceAccountShortTermTokenMinter"
    members = [
      "serviceAccount:service-${var.project_number}@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/iam.serviceAccountTokenCreator"
    members = [
      "serviceAccount:service-${var.project_number}@gcp-sa-pubsub.iam.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/logging.logWriter"
    members = [
      google_service_account.workflow_govuk_database_backups.member,
      google_service_account.workflow_redis_cli.member,
      google_service_account.gce_whitehall.member,
      google_service_account.gce_asset_manager.member
    ]
  }

  binding {
    role = "roles/logging.bucketWriter"
    members = [
      google_service_account.log_writer.member,
    ]
  }

  binding {
    role = "roles/networkmanagement.serviceAgent"
    members = [
      "serviceAccount:service-${var.project_number}@gcp-sa-networkmanagement.iam.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/pubsub.serviceAgent"
    members = [
      "serviceAccount:service-${var.project_number}@gcp-sa-pubsub.iam.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/workflows.invoker"
    members = [
      google_service_account.eventarc.member,
    ]
  }

  binding {
    role = "roles/run.admin"
    members = [
      google_service_account.govgraphsearch_deploy.member,
    ]
  }

  binding {
    role = "roles/run.developer"
    members = [
      # To deploy to Cloud Run from GitHub Actions, which use the
      # artifact_registr_docker account to build and push the image that is then
      # deployed to Cloud Run.
      google_service_account.artifact_registry_docker.member,
    ]
  }

  binding {
    role = "roles/run.serviceAgent"
    members = [
      "serviceAccount:service-${var.project_number}@serverless-robot-prod.iam.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/serviceusage.serviceUsageConsumer"
    members = [
      google_service_account.govgraphsearch_deploy.member,
    ]
  }

  binding {
    role = "roles/storage.admin"
    members = [
      google_service_account.govgraphsearch_deploy.member,
    ]
  }

  binding {
    role = "roles/vpcaccess.serviceAgent"
    members = [
      "serviceAccount:service-${var.project_number}@gcp-sa-vpcaccess.iam.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/workflows.serviceAgent"
    members = [
      "serviceAccount:service-${var.project_number}@gcp-sa-workflows.iam.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/workflows.invoker"
    members = [
      google_service_account.workflow_smart_survey.member,
      google_service_account.workflow_zendesk.member,
    ]
  }

  binding {
    role = "roles/redis.admin"
    members = [
      google_service_account.gce_redis_cli.member,
    ]
  }

  # Add the necessary role and member for Redis service account
  binding {
    role = "roles/redis.serviceAgent"
    members = [
      "serviceAccount:service-${var.project_number}@cloud-redis.iam.gserviceaccount.com"
    ]
  }
}

variable "name" {
  type        = string
  description = "A short name for this environment (used in resource IDs)"
}
