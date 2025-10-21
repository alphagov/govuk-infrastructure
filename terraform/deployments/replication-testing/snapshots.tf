locals {
  take_snapshots_of = toset(
    var.encrypt_databases ? [
      "jfharden-test-content-data-api-001-postgres",
      "jfharden-test-whitehall-001-mysql",
      "jfharden-test-publishing-api-postgres",
    ] : []
  )
}

resource "aws_db_snapshot" "unencrypted" {
  for_each = local.take_snapshots_of

  # This is purposefully not using the actual terraform resource to ensure it doesn't get destroyed if the
  # aws_db_instance gets destroyed.
  db_instance_identifier = each.key
  db_snapshot_identifier = "${each.key}-pre-encryption"

  timeouts {
    create = "2h"
  }
}

resource "aws_db_snapshot_copy" "encrypted" {
  for_each = aws_db_snapshot.unencrypted

  source_db_snapshot_identifier = aws_db_snapshot.unencrypted[each.key].db_snapshot_arn
  target_db_snapshot_identifier = "${each.key}-post-encryption"
  kms_key_id                    = aws_kms_key.rds.arn

  timeouts {
    create = "2h"
  }
}
