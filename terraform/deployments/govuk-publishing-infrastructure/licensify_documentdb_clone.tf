# This is a temporary clone of Licensing's DocDB cluster
# It is for testing an upgrade to DocDB 5.x

data "aws_db_cluster_snapshot" "licensify_cluster_snapshot" {
  db_cluster_identifier = aws_docdb_cluster.licensify_cluster.id
  most_recent           = true
}

resource "aws_docdb_cluster" "licensify_cluster_clone" {
  count                           = var.create_licensify_documentdb_clone ? 1 : 0
  cluster_identifier              = "licensify-documentdb-clone-${var.govuk_environment}"
  db_subnet_group_name            = aws_docdb_subnet_group.licensify_cluster_subnet.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.licensify_parameter_group.name
  master_username                 = "master"
  master_password                 = random_password.licensify_documentdb_master.result
  storage_encrypted               = true
  kms_key_id                      = aws_kms_key.licensify_documentdb_kms_key.arn
  vpc_security_group_ids          = [data.tfe_outputs.security.nonsensitive_values.govuk_licensify-documentdb_access_sg_id]
  enabled_cloudwatch_logs_exports = ["profiler"]
  backup_retention_period         = 1
  snapshot_identifier             = data.aws_db_cluster_snapshot.licensify_cluster_snapshot.id
  engine_version                  = "3.6.0"
}

resource "aws_docdb_cluster_instance" "licensify_cluster_clone_instances" {
  count              = var.create_licensify_documentdb_clone ? 1 : 0
  identifier         = "licensify-documentdb-clone-0"
  cluster_identifier = aws_docdb_cluster.licensify_cluster_clone[0].id
  instance_class     = "db.r5.large"
  tags               = aws_docdb_cluster.licensify_cluster_clone[0].tags
}

resource "aws_route53_record" "licensify_documentdb_clone" {
  count   = var.create_licensify_documentdb_clone ? 1 : 0
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "licensify-documentdb-clone.${var.govuk_environment}.govuk-internal.digital"
  type    = "CNAME"
  ttl     = 300
  records = [aws_docdb_cluster.licensify_cluster_clone[0].endpoint]
}
