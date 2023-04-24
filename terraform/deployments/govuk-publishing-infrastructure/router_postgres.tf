resource "aws_db_subnet_group" "private_subnet" {
  name       = "govuk-rds-subnet"
  subnet_ids = data.terraform_remote_state.infra_networking.outputs.private_subnet_rds_ids
}

resource "aws_rds_cluster" "router" {
  cluster_identifier          = "router-postgres"
  database_name               = "router"
  engine                      = "aurora-postgresql"
  engine_version              = "11"
  manage_master_user_password = true
  master_username             = "aws_db_admin"
  db_subnet_group_name        = aws_db_subnet_group.private_subnet.name
}

resource "aws_route53_record" "router_db" {
  zone_id = data.terraform_remote_state.infra_root_dns_zones.outputs.internal_root_zone_id
  name    = "router-postgres"
  type    = "CNAME"
  ttl     = 300
  records = [aws_rds_cluster.router.endpoint]
}
