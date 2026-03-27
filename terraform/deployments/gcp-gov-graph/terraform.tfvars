folder_id       = "278098142879"
billing_account = "015C7A-FAF970-B0D375"
region          = "europe-west2"
zone            = "europe-west2-b"
location        = "EUROPE-WEST2"

services = [
  "storage.googleapis.com",
  "iam.googleapis.com",
  "appengine.googleapis.com",
  "artifactregistry.googleapis.com",
  "cloudscheduler.googleapis.com",
  "cloudfunctions.googleapis.com",
  "bigquery.googleapis.com",
  "bigqueryconnection.googleapis.com",
  "bigquerydatatransfer.googleapis.com",
  "run.googleapis.com",
  "compute.googleapis.com",
  "dns.googleapis.com",
  "eventarc.googleapis.com",
  "networkmanagement.googleapis.com",
  "pubsub.googleapis.com",
  "sourcerepo.googleapis.com",
  "vpcaccess.googleapis.com",
  "workflows.googleapis.com",
  "iap.googleapis.com",
  "secretmanager.googleapis.com",
  "redis.googleapis.com",
  "dlp.googleapis.com",
  "cloudquotas.googleapis.com"
]

postgres-startup-script = <<EOF
#cloud-config

bootcmd:
- mkfs.ext4 -F /dev/nvme0n1
- mkdir -p /mnt/disks/local-ssd
- mount -o discard,defaults,nobarrier /dev/nvme0n1 /mnt/disks/local-ssd
- mkdir -p /mnt/disks/local-ssd/postgresql-data
- mkdir -p /mnt/disks/local-ssd/data
EOF

alerts_error_message_old_data = "Old data in table"
alerts_error_message_no_data  = "No data in table"
