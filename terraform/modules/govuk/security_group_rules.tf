# Security group rules for controlling traffic in/out of GOV.UK Publishing
# microservices are defined here.
#
# The rationale for keeping these definitions here is that it simplifies
# maintenance and allows reading the whole policy in one place. We could define
# the rules in the individual app modules, but then we'd still need to pass the
# SG IDs around as parameters via the `govuk` module anyway (and inputs.tf and
# outputs.tf in the various app modules). It's much simpler therefore to define
# them here and save having to edit multiple modules and plumb variables
# through lots of different files in order to make simple changes.
#
# Naming: please use the following conventions where appropriate:
# For ingress rules:
#   Name: {destination}_from_{source}_{protocol}
#   Description: {destination} accepts requests from {source} over {protocol}
# For egress rules:
#   Name: {source}_to_{destination}_{protocol}
#   Description: {source} sends requests to {destination} over {protocol}

resource "aws_security_group_rule" "content_store_from_publishing_api_http" {
  description              = "Content Store accepts requests from Publishing API over HTTP"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.content_store_service.app_security_group_id
  source_security_group_id = module.publishing_api_service.app_security_group_id
}

resource "aws_security_group_rule" "draft_content_store_from_publishing_api_http" {
  description              = "Draft Content Store accepts requests from Publishing API over HTTP"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.draft_content_store_service.app_security_group_id
  source_security_group_id = module.publishing_api_service.app_security_group_id
}

resource "aws_security_group_rule" "content_store_from_frontend_http" {
  description              = "Content Store accepts requests from Frontend over HTTP"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.content_store_service.app_security_group_id
  source_security_group_id = module.frontend_service.app_security_group_id
}

resource "aws_security_group_rule" "draft_content_store_from_frontend_http" {
  description              = "Draft Content Store accepts requests from Draft Frontend over HTTP"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.draft_content_store_service.app_security_group_id
  source_security_group_id = module.draft_frontend_service.app_security_group_id
}

# TODO: fix overly broad egress rules
resource "aws_security_group_rule" "content_store_to_any_any" {
  description       = "Content Store sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.content_store_service.app_security_group_id
}

resource "aws_security_group_rule" "publisher_to_any_any" {
  description       = "Publisher sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.publisher_service.app_security_group_id
}

resource "aws_security_group_rule" "publisher_from_alb_http" {
  description              = "Publisher receives requests from its public ALB over HTTP"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.publisher_service.app_security_group_id
  source_security_group_id = module.publisher_service.alb_security_group_id
}

resource "aws_security_group_rule" "publisher_alb_to_publisher_http" {
  description              = "Publisher ALB sends requests to Publisher over HTTP"
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.publisher_service.alb_security_group_id
  source_security_group_id = module.publisher_service.app_security_group_id
}

resource "aws_security_group_rule" "publisher_alb_from_any_https" {
  description       = "Publisher ALB receives requests from anywhere over HTTPS"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.publisher_service.alb_security_group_id
}

resource "aws_security_group_rule" "redis_from_publisher_resp" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = module.shared_redis_cluster.security_group_id
  source_security_group_id = module.publisher_service.app_security_group_id
}

resource "aws_security_group_rule" "postgres_from_publishing_api_5432" {
  description = "Postgres RDS accepts requests from Publishing API"
  type        = "ingress"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"

  security_group_id        = var.postgresql_security_group_id
  source_security_group_id = module.publishing_api_service.app_security_group_id
}

resource "aws_security_group_rule" "redis_from_publishing_api_resp" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = module.shared_redis_cluster.security_group_id
  source_security_group_id = module.publishing_api_service.app_security_group_id
}

resource "aws_security_group_rule" "documentdb_from_publisher_mongodb" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = var.documentdb_security_group_id
  source_security_group_id = module.publisher_service.app_security_group_id
}

resource "aws_security_group_rule" "publishing_api_from_publisher_http" {
  description = "Publishing API accepts requests from Publisher over HTTP"
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"

  security_group_id        = module.publishing_api_service.app_security_group_id
  source_security_group_id = module.publisher_service.app_security_group_id
}

resource "aws_security_group_rule" "publishing_api_from_frontend_http" {
  description = "Publishing API accepts requests from Frontend over HTTP"
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"

  security_group_id        = module.publishing_api_service.app_security_group_id
  source_security_group_id = module.frontend_service.app_security_group_id
}

resource "aws_security_group_rule" "frontend_to_any_any" {
  description       = "Frontend sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.frontend_service.app_security_group_id
}

resource "aws_security_group_rule" "frontend_from_alb_http" {
  description              = "Frontend receives requests from its public ALB over HTTP"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.frontend_service.app_security_group_id
  source_security_group_id = module.frontend_service.alb_security_group_id
}

resource "aws_security_group_rule" "frontend_alb_from_office_https" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  security_group_id = module.frontend_service.alb_security_group_id
  cidr_blocks       = var.office_cidrs_list
}

resource "aws_security_group_rule" "frontend_alb_to_any_any" {
  type      = "egress"
  protocol  = "-1"
  from_port = 0
  to_port   = 0

  security_group_id = module.frontend_service.alb_security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "draft_frontend_to_any_any" {
  description       = "Draft Frontend sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.draft_frontend_service.app_security_group_id
}

resource "aws_security_group_rule" "draft_frontend_from_alb_http" {
  description              = "Draft Frontend receives requests from its public ALB over HTTP"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.draft_frontend_service.app_security_group_id
  source_security_group_id = module.draft_frontend_service.alb_security_group_id
}

resource "aws_security_group_rule" "draft_frontend_alb_from_office_https" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  security_group_id = module.draft_frontend_service.alb_security_group_id
  cidr_blocks       = var.office_cidrs_list
}

resource "aws_security_group_rule" "draft_frontend_alb_to_any_any" {
  type      = "egress"
  protocol  = "-1"
  from_port = 0
  to_port   = 0

  security_group_id = module.draft_frontend_service.alb_security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
}


data "aws_nat_gateway" "govuk" {
  count     = length(var.public_subnets)
  subnet_id = var.public_subnets[count.index]
}

resource "aws_security_group_rule" "frontend_alb_from_test_nat_gateways_https" {
  description = "Frontend ALB receives HTTPS requests from apps in ECS"
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"

  security_group_id = module.frontend_service.alb_security_group_id
  cidr_blocks = [
    for nat_gateway in data.aws_nat_gateway.govuk :
    "${nat_gateway.public_ip}/32"
  ]
}

resource "aws_security_group_rule" "static_to_any_any" {
  description       = "Static sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.static_service.app_security_group_id
}

resource "aws_security_group_rule" "static_from_alb_http" {
  description              = "Static receives requests from its public ALB over HTTP"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.static_service.app_security_group_id
  source_security_group_id = module.static_service.alb_security_group_id
}

resource "aws_security_group_rule" "static_alb_from_office_https" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  security_group_id = module.static_service.alb_security_group_id
  cidr_blocks       = var.office_cidrs_list
}

resource "aws_security_group_rule" "static_from_frontend_http" {
  description              = "Static receives requests from Frontend over HTTP"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.static_service.app_security_group_id
  source_security_group_id = module.frontend_service.app_security_group_id
}

resource "aws_security_group_rule" "static_alb_to_any_any" {
  type      = "egress"
  protocol  = "-1"
  from_port = 0
  to_port   = 0

  security_group_id = module.static_service.alb_security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "draft_static_to_any_any" {
  description       = "Draft Static sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.draft_static_service.app_security_group_id
}

resource "aws_security_group_rule" "draft_static_from_alb_http" {
  description              = "Draft Static receives requests from its public ALB over HTTP"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.draft_static_service.app_security_group_id
  source_security_group_id = module.draft_static_service.alb_security_group_id
}

resource "aws_security_group_rule" "draft_static_alb_from_office_https" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  security_group_id = module.draft_static_service.alb_security_group_id
  cidr_blocks       = var.office_cidrs_list
}

resource "aws_security_group_rule" "draft_static_from_frontend_http" {
  description              = "Draft Static receives requests from Draft Frontend over HTTP"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.draft_static_service.app_security_group_id
  source_security_group_id = module.draft_frontend_service.app_security_group_id
}

resource "aws_security_group_rule" "draft_static_alb_to_any_any" {
  type      = "egress"
  protocol  = "-1"
  from_port = 0
  to_port   = 0

  security_group_id = module.draft_static_service.alb_security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "mongodb_from_content_store_mongodb" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = var.mongodb_security_group_id
  source_security_group_id = module.content_store_service.app_security_group_id
}

resource "aws_security_group_rule" "mongodb_from_draft_content_store_mongodb" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = var.mongodb_security_group_id
  source_security_group_id = module.draft_content_store_service.app_security_group_id
}

resource "aws_security_group_rule" "router_api_from_content_store_http" {
  description = "Router API accepts requests from Content Store over HTTP"
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"

  security_group_id        = module.router_api_service.app_security_group_id
  source_security_group_id = module.content_store_service.app_security_group_id
}

resource "aws_security_group_rule" "routerdb_from_router_api_mongodb" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = var.routerdb_security_group_id
  source_security_group_id = module.router_api_service.app_security_group_id
}

resource "aws_security_group_rule" "routerdb_from_draft_router_api_mongodb" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = var.routerdb_security_group_id
  source_security_group_id = module.draft_router_api_service.app_security_group_id
}

resource "aws_security_group_rule" "draft_router_api_from_draft_content_store_http" {
  description = "Draft Router API accepts requests from Draft Content Store over HTTP"
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"

  security_group_id        = module.draft_router_api_service.app_security_group_id
  source_security_group_id = module.draft_content_store_service.app_security_group_id
}

resource "aws_security_group_rule" "routerdb_from_router_mongodb" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = var.routerdb_security_group_id
  source_security_group_id = module.router_service.app_security_group_id
}

resource "aws_security_group_rule" "router_from_router_api_tcp" {
  description = "Router accepts requests from Router API over TCP"
  type        = "ingress"
  from_port   = 3055
  to_port     = 3055
  protocol    = "tcp"

  security_group_id        = module.router_service.app_security_group_id
  source_security_group_id = module.router_api_service.app_security_group_id
}

resource "aws_security_group_rule" "routerdb_from_draft_router_mongodb" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = var.routerdb_security_group_id
  source_security_group_id = module.draft_router_service.app_security_group_id
}

resource "aws_security_group_rule" "draft_router_from_draft_router_api_tcp" {
  description = "Draft Router accepts requests from Draft Router API over TCP"
  type        = "ingress"
  from_port   = 3055
  to_port     = 3055
  protocol    = "tcp"

  security_group_id        = module.draft_router_service.app_security_group_id
  source_security_group_id = module.draft_router_api_service.app_security_group_id
}

resource "aws_security_group_rule" "redis_to_any_any" {
  description       = "Redis cluster sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.shared_redis_cluster.security_group_id
}

resource "aws_security_group_rule" "redis_from_signon_resp" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = module.shared_redis_cluster.security_group_id
  source_security_group_id = module.signon_service.app_security_group_id
}

resource "aws_security_group_rule" "mysql_from_signon_mysql" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = var.mysql_security_group_id
  source_security_group_id = module.signon_service.app_security_group_id
}

resource "aws_security_group_rule" "signon_to_any_any" {
  description       = "Signon sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.signon_service.app_security_group_id
}

# TODO: move the rest of the rules into this file unless there's a good reason
#       for them to stay in other files.

# TODO: create SG rules for UDP ingress from apps to Statsd (tons, find shorthand)

resource "aws_security_group" "statsd_service" {
  name        = "fargate_statsd"
  vpc_id      = var.vpc_id
  description = "Statsd ECS Service"
}

resource "aws_security_group_rule" "statsd_from_signon_udp" {
  type                     = "egress"
  from_port                = "8125"
  to_port                  = "8125"
  protocol                 = "udp"
  security_group_id        = aws_security_group.statsd_service.id
  source_security_group_id = module.signon_service.app_security_group_id
}
