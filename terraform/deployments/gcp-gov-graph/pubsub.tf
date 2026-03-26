resource "google_pubsub_topic" "govuk_database_backups" {
  name                       = "govuk-database-backups"
  message_retention_duration = "604800s" # 604800 seconds is 7 days
  message_storage_policy {
    allowed_persistence_regions = [
      var.region,
    ]
  }
}

// Allow the govuk-s3-mirror project's bucket to publish to this topic
data "google_iam_policy" "pubsub_topic-govuk_database_backups" {
  binding {
    role = "roles/pubsub.publisher"
    members = [
      "serviceAccount:service-384988117066@gs-project-accounts.iam.gserviceaccount.com"
    ]
  }
}

resource "google_pubsub_topic_iam_policy" "govuk_database_backups" {
  topic       = google_pubsub_topic.govuk_database_backups.name
  policy_data = data.google_iam_policy.pubsub_topic-govuk_database_backups.policy_data
}

# Subscribe to the topic
resource "google_pubsub_subscription" "govuk_database_backups" {
  name  = "govuk-database-backups"
  topic = google_pubsub_topic.govuk_database_backups.name

  message_retention_duration = "604800s" # 604800 seconds is 7 days
  retain_acked_messages      = true

  expiration_policy {
    ttl = "" # empty string is 'never'
  }

  enable_message_ordering = false
}
