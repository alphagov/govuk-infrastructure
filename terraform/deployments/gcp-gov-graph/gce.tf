data "google_compute_default_service_account" "default" {
}
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

# Create some service accounts

resource "google_service_account" "gce_publishing_api" {
  account_id   = "gce-publishing-api"
  display_name = "Service Account for the publishing-api instance"
  description  = "Service account for the publishing-api instance on GCE"
}

resource "google_service_account" "gce_support_api" {
  account_id   = "gce-support-api"
  display_name = "Service Account for the support-api instance"
  description  = "Service account for the support-api instance on GCE"
}

resource "google_service_account" "gce_publisher" {
  account_id   = "gce-publisher"
  display_name = "Service Account for the Publisher mongobd instance"
  description  = "Service Account for the Publisher mongodb instance on GCE"
}

resource "google_service_account" "gce_redis_cli" {
  account_id   = "gce-redis-cli"
  display_name = "Service Account for the Redis CLI instance"
  description  = "Service Account for the Redis CLI instance on GCE"
}

resource "google_service_account" "gce_whitehall" {
  account_id   = "gce-whitehall"
  display_name = "Service Account for the whitehall instance"
  description  = "Service account for the whitehall instance on GCE"
}

resource "google_service_account" "gce_asset_manager" {
  account_id   = "gce-asset-manager"
  display_name = "Service Account for the asset-manager instance"
  description  = "Service account for the asset-manager instance on GCE"
}

# Allow a workflow to attach the publishing-api service account to an instance.
data "google_iam_policy" "service_account-gce_publishing_api" {
  binding {
    role = "roles/iam.serviceAccountUser"
    members = [
      google_service_account.workflow_govuk_database_backups.member,
    ]
  }
}

resource "google_service_account_iam_policy" "gce_publishing_api" {
  service_account_id = google_service_account.gce_publishing_api.name
  policy_data        = data.google_iam_policy.service_account-gce_publishing_api.policy_data
}

# Allow a workflow to attach the support-api service account to an instance.
data "google_iam_policy" "service_account-gce_support_api" {
  binding {
    role = "roles/iam.serviceAccountUser"
    members = [
      google_service_account.workflow_govuk_database_backups.member,
    ]
  }
}

resource "google_service_account_iam_policy" "gce_support_api" {
  service_account_id = google_service_account.gce_support_api.name
  policy_data        = data.google_iam_policy.service_account-gce_support_api.policy_data
}

# Allow a workflow to attach the publisher service account to an instance.
data "google_iam_policy" "service_account-gce_publisher" {
  binding {
    role = "roles/iam.serviceAccountUser"
    members = [
      google_service_account.workflow_govuk_database_backups.member,
    ]
  }
}

resource "google_service_account_iam_policy" "gce_publisher" {
  service_account_id = google_service_account.gce_publisher.name
  policy_data        = data.google_iam_policy.service_account-gce_publisher.policy_data
}


# Allow a workflow to attach the redis-cli service account to an instance.
data "google_iam_policy" "service_account-gce_redis_cli" {
  binding {
    role = "roles/iam.serviceAccountUser"
    members = [
      google_service_account.workflow_redis_cli.member,
    ]
  }
}

resource "google_service_account_iam_policy" "gce_redis_cli" {
  service_account_id = google_service_account.gce_redis_cli.name
  policy_data        = data.google_iam_policy.service_account-gce_redis_cli.policy_data
}

# Allow a workflow to attach the whitehall service account to an instance.
data "google_iam_policy" "service_account-gce_whitehall" {
  binding {
    role = "roles/iam.serviceAccountUser"
    members = [
      google_service_account.workflow_govuk_database_backups.member,
    ]
  }
}

resource "google_service_account_iam_policy" "gce_whitehall" {
  service_account_id = google_service_account.gce_whitehall.name
  policy_data        = data.google_iam_policy.service_account-gce_whitehall.policy_data
}

# Allow a workflow to attach the asset-manager service account to an instance.
data "google_iam_policy" "service_account-gce_asset_manager" {
  binding {
    role = "roles/iam.serviceAccountUser"
    members = [
      google_service_account.workflow_govuk_database_backups.member,
    ]
  }
}

resource "google_service_account_iam_policy" "gce_asset_manager" {
  service_account_id = google_service_account.gce_asset_manager.name
  policy_data        = data.google_iam_policy.service_account-gce_asset_manager.policy_data
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

# https://github.com/terraform-google-modules/terraform-google-container-vm
module "publishing-api-container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 2.0"

  container = {
    image = "${var.region}-docker.pkg.dev/${var.project_id}/docker/publishing-api:latest"
    tty : true
    stdin : true
    securityContext = {
      privileged : true
    }
    env = [
      {
        name  = "POSTGRES_HOST_AUTH_METHOD"
        value = "trust"
      },
      {
        name  = "PROJECT_ID"
        value = var.project_id
      },
      {
        name  = "ZONE"
        value = var.zone
      }
    ]
  }

  restart_policy = "Never"
}

# https://github.com/terraform-google-modules/terraform-google-container-vm
module "support-api-container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 2.0"

  container = {
    image = "${var.region}-docker.pkg.dev/${var.project_id}/docker/support-api:latest"
    tty : true
    stdin : true
    securityContext = {
      privileged : true
    }
    env = [
      {
        name  = "POSTGRES_HOST_AUTH_METHOD"
        value = "trust"
      },
      {
        name  = "PROJECT_ID"
        value = var.project_id
      },
      {
        name  = "ZONE"
        value = var.zone
      }
    ]
    volumeMounts = [
      {
        mountPath = "/var/lib/postgresql/data"
        name      = "local-ssd-postgresql-data"
        readOnly  = false
      },
      {
        mountPath = "/data"
        name      = "local-ssd-data"
        readOnly  = false
      }
    ]
  }

  volumes = [
    # https://github.com/terraform-google-modules/terraform-google-container-vm/issues/66
    {
      name = "local-ssd-postgresql-data"
      hostPath = {
        path = "/mnt/disks/local-ssd/postgresql-data"
      }
    },
    {
      name = "local-ssd-data"
      hostPath = {
        path = "/mnt/disks/local-ssd/data"
      }
    }
  ]

  restart_policy = "Never"
}

# https://github.com/terraform-google-modules/terraform-google-container-vm
module "publisher-container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 2.0"

  container = {
    image = "${var.region}-docker.pkg.dev/${var.project_id}/docker/publisher:latest"
    tty : true
    stdin : true
    volumeMounts = [
      {
        mountPath = "/data/db"
        name      = "tempfs-0"
        readOnly  = false
      },
      {
        mountPath = "/data/configdb"
        name      = "tempfs-1"
        readOnly  = false
      },
    ]
    env = [
      {
        name  = "PROJECT_ID"
        value = var.project_id
      },
      {
        name  = "ZONE"
        value = var.zone
      }
    ]
  }

  # Declare the Volumes which will be used for mounting.
  volumes = [
    {
      name = "tempfs-0"

      emptyDir = {
        medium = "Memory"
      }
    },
    {
      name = "tempfs-1"

      emptyDir = {
        medium = "Memory"
      }
    },
  ]

  restart_policy = "Never"
}

# https://github.com/terraform-google-modules/terraform-google-container-vm
module "redis-cli-container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 2.0"

  # Enable / Disable
  count = var.enable_redis_session_store_instance ? 1 : 0

  container = {
    image = "${var.region}-docker.pkg.dev/${var.project_id}/docker/redis-cli:latest"
    tty : true
    stdin : true
    env = [
      {
        name  = "PROJECT_ID"
        value = var.project_id
      },
      {
        name  = "REGION"
        value = var.region
      },
      {
        name  = "ZONE"
        value = var.zone
      },
      {
        name  = "REDIS_HOST"
        value = google_redis_instance.session_store[0].host
      },
      {
        name  = "REDIS_PORT"
        value = google_redis_instance.session_store[0].port
      }
    ]
  }


  restart_policy = "Never"
}

module "whitehall-container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 2.0"

  container = {
    image = "${var.region}-docker.pkg.dev/${var.project_id}/docker/whitehall:latest"
    tty : true
    stdin : true
    securityContext = {
      privileged : true
    }
    env = [
      {
        name  = "PROJECT_ID"
        value = var.project_id
      },
      {
        name  = "ZONE"
        value = var.zone
      }
    ]
  }

  restart_policy = "Never"
}

module "asset-manager-container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 2.0"

  container = {
    image = "${var.region}-docker.pkg.dev/${var.project_id}/docker/asset-manager:latest"
    tty : true
    stdin : true
    securityContext = {
      privileged : true
    }
    env = [
      {
        name  = "PROJECT_ID"
        value = var.project_id
      },
      {
        name  = "ZONE"
        value = var.zone
      }
    ]
  }

  restart_policy = "Never"
}

resource "google_compute_instance_template" "publishing_api" {
  name = "publishing-api"
  # 2 CPUs are enough that, while the largest table is being restored, all the
  # other tables will also be restored, even if some of them are done in series
  # rather than parallel.  Not much memory is required.  See postgresql.conf for
  # the memory allowances.
  machine_type = "c2d-highmem-2"

  disk {
    boot         = true
    source_image = module.publishing-api-container.source_image
    disk_size_gb = 1024
  }

  metadata = {
    # https://cloud.google.com/container-optimized-os/docs/concepts/disks-and-filesystem#mounting_and_formatting_disks
    user-data                  = var.postgres-startup-script
    google-logging-enabled     = true
    serial-port-logging-enable = true
    gce-container-declaration  = module.publishing-api-container.metadata_value
  }

  network_interface {
    network = "default"
    access_config {
      network_tier = "STANDARD"
    }
  }

  service_account {
    email  = google_service_account.gce_publishing_api.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance_template" "support_api" {
  name = "support-api"
  # 2 CPUs are enough that, while the largest table is being restored, all the
  # other tables will also be restored, even if some of them are done in series
  # rather than parallel.  Not much memory is required.  See postgresql.conf for
  # the memory allowances.
  machine_type = "c2d-highmem-2"

  disk {
    boot         = true
    source_image = module.support-api-container.source_image
    disk_size_gb = 10
  }

  disk {
    device_name  = "local-ssd"
    interface    = "NVME"
    disk_type    = "local-ssd"
    disk_size_gb = "375" # Must be exactly 375GB for a local SSD disk
    type         = "SCRATCH"
  }

  metadata = {
    # https://cloud.google.com/container-optimized-os/docs/concepts/disks-and-filesystem#mounting_and_formatting_disks
    user-data                  = var.postgres-startup-script
    google-logging-enabled     = true
    serial-port-logging-enable = true
    gce-container-declaration  = module.support-api-container.metadata_value
  }

  network_interface {
    network = "default"
    access_config {
      network_tier = "STANDARD"
    }
  }

  service_account {
    email  = google_service_account.gce_support_api.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance_template" "publisher" {
  name         = "publisher"
  machine_type = "e2-highcpu-32"

  disk {
    boot         = true
    source_image = module.publisher-container.source_image
    disk_size_gb = 10
  }

  metadata = {
    google-logging-enabled     = true
    serial-port-logging-enable = true
    gce-container-declaration  = module.publisher-container.metadata_value
  }

  network_interface {
    network = "default"
    access_config {
      network_tier = "STANDARD"
    }
  }

  service_account {
    email  = google_service_account.gce_publisher.email
    scopes = ["cloud-platform"]
  }
}

# Template for occasional use, such as debugging
resource "google_compute_instance_template" "redis_cli" {
  name         = "redis-cli"
  machine_type = "e2-medium"

  # Enable / Disable
  count = var.enable_redis_session_store_instance ? 1 : 0

  disk {
    boot         = true
    source_image = module.redis-cli-container[0].source_image
    disk_size_gb = 10
  }

  metadata = {
    google-logging-enabled     = true
    serial-port-logging-enable = true
    gce-container-declaration  = module.redis-cli-container[0].metadata_value
  }

  network_interface {
    network = "default"
    access_config {
      network_tier = "STANDARD"
    }
  }

  service_account {
    email  = google_service_account.gce_redis_cli.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance_template" "whitehall" {
  name         = "whitehall"
  machine_type = "c2d-highmem-2"

  disk {
    boot         = true
    source_image = module.whitehall-container.source_image
    disk_size_gb = 64
  }

  metadata = {
    google-logging-enabled     = true
    serial-port-logging-enable = true
    gce-container-declaration  = module.whitehall-container.metadata_value
  }

  network_interface {
    network = "default"
    access_config {
      network_tier = "STANDARD"
    }
  }

  service_account {
    email  = google_service_account.gce_whitehall.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance_template" "asset_manager" {
  name         = "asset-manager"
  machine_type = "c2d-highmem-2"

  disk {
    boot         = true
    source_image = module.asset-manager-container.source_image
    disk_size_gb = 64
  }

  metadata = {
    google-logging-enabled     = true
    serial-port-logging-enable = true
    gce-container-declaration  = module.asset-manager-container.metadata_value
  }

  network_interface {
    network = "default"
    access_config {
      network_tier = "STANDARD"
    }
  }

  service_account {
    email  = google_service_account.gce_asset_manager.email
    scopes = ["cloud-platform"]
  }
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

  target_service_accounts = [
    google_service_account.gce_redis_cli.email
  ]
}
