variable "db_mass_test" {
  type        = bool
  description = "Perform snapshot, snapshot copy, and create encrypted instance for every db in local.instances"
  default     = false
}

locals {
  instances = toset([
    "account-api-postgres",
    "authenticating-proxy-postgres",
    "blue-content-data-api-postgresql-primary-postgres",
    "ckan-postgres",
    "collections-publisher-mysql",
    "content-block-manager-postgres",
    "content-data-admin-postgres",
    "content-publisher-postgres",
    "content-store-postgres",
    "content-tagger-postgres",
    "draft-content-store-postgres",
    "email-alert-api-postgres",
    "imminence-postgres",
    "link-checker-api-postgres",
    "local-links-manager-postgres",
    "locations-api-postgres",
    "publisher-postgres",
    "publishing-api-postgres",
    "release-mysql",
    "search-admin-mysql",
    "service-manual-publisher-postgres",
    "signon-mysql",
    "support-api-postgres",
    "transition-postgres",
    "whitehall-mysql",
  ])
}

data "aws_db_instance" "mass_db_lookup" {
  for_each = var.db_mass_test ? local.instances : toset([])

  db_instance_identifier = each.key
}


resource "aws_db_snapshot" "unencrypted_mass_test" {
  for_each = var.db_mass_test ? data.aws_db_instance.mass_db_lookup : {}

  db_instance_identifier = each.value.db_instance_identifier
  db_snapshot_identifier = "jfharden-mass-${each.value.db_instance_identifier}-pre-encryption"

  timeouts {
    create = "4h"
  }
}

resource "aws_db_snapshot_copy" "encrypted_mass_db" {
  for_each = var.db_mass_test ? data.aws_db_instance.mass_db_lookup : {}

  source_db_snapshot_identifier = aws_db_snapshot.unencrypted_mass_test[each.key].db_snapshot_arn
  target_db_snapshot_identifier = "jfharden-mass-${each.value.db_instance_identifier}-post-encryption"
  kms_key_id                    = aws_kms_key.rds.arn

  timeouts {
    create = "4h"
  }
}

resource "aws_db_instance" "mass_create" {
  for_each = var.db_mass_test ? data.aws_db_instance.mass_db_lookup : {}

  identifier            = "jfharden-mass-${each.value.db_instance_identifier}"
  engine                = each.value.engine
  engine_version        = each.value.engine_version
  instance_class        = each.value.db_instance_class
  deletion_protection   = false
  apply_immediately     = true
  copy_tags_to_snapshot = true
  monitoring_interval   = 60
  monitoring_role_arn   = "arn:aws:iam::210287912431:role/rds-monitoring-role"
  skip_final_snapshot   = true
  multi_az              = true
  allocated_storage     = each.value.allocated_storage
  parameter_group_name  = each.value.db_parameter_groups[0]
  tags = merge(
    each.value.tags,
    {
      TestType = "Mass Parallelism"
    }
  )
  snapshot_identifier = aws_db_snapshot_copy.encrypted_mass_db[each.key].target_db_snapshot_identifier

  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn

  timeouts {
    create = "2h"
  }
}
