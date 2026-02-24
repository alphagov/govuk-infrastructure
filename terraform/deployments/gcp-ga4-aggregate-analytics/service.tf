locals {
  services = [
    "bigquery.googleapis.com",
    "bigquerydatatransfer.googleapis.com",
    "storage.googleapis.com",
  ]
}

resource "google_project_service" "project_services" {
  for_each = toset(local.services)
  service  = each.key

  disable_on_destroy = false
}
