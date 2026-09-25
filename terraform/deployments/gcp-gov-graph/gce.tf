data "google_compute_default_service_account" "default" {}

data "google_iam_policy" "compute_default_service_account" {
  binding {
    role = "roles/iam.serviceAccountUser"

    members = [
      google_service_account.artifact_registry_docker.member,
    ]
  }
}

resource "google_service_account_iam_policy" "compute_default_service_account" {
  service_account_id = data.google_compute_default_service_account.default.name
  policy_data        = data.google_iam_policy.compute_default_service_account.policy_data
}

# terraform import google_compute_network.default default
resource "google_compute_network" "default" {
  name        = "default"
  description = "Default network for the project"
}

# Network for GovGraph Search
resource "google_compute_network" "cloudrun" {
  name                            = "custom-vpc-for-cloud-run"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
  enable_ula_internal_ipv6        = false
  mtu                             = 1460
  project                         = var.project_id
  routing_mode                    = "REGIONAL"
}

# Subnet for GovGraph Search
resource "google_compute_subnetwork" "cloudrun" {
  name                       = "cloudrun-subnet"
  ip_cidr_range              = "10.8.0.0/28"
  network                    = google_compute_network.cloudrun.id
  private_ip_google_access   = true # otherwise containers won't start
  private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
  project                    = var.project_id
  purpose                    = "PRIVATE"
  region                     = var.region
  stack_type                 = "IPV4_ONLY"
}

# Project-level metadata, on all machines
resource "google_compute_project_metadata" "default" {
  metadata = {
    google-logging-enabled     = true
    serial-port-logging-enable = true
  }
}

resource "google_compute_firewall" "default_allow_iap_ssh" {
  name        = "default-allow-iap-ssh"
  description = "Allow ingress via IAP"
  network     = google_compute_network.default.name
  priority    = 65534

  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "custom_vpc_for_cloud_run_allow_iap_ssh" {
  name        = "custom-vpc-for-cloud-run-allow-iap-ssh"
  description = "Allow ingress via IAP"
  network     = google_compute_network.cloudrun.name
  priority    = 65534

  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
