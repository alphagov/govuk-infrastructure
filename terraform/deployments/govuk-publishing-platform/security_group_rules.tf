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
  security_group_id        = module.content_store.security_group_id
  source_security_group_id = module.publishing_api_web.security_group_id
}

resource "aws_security_group_rule" "draft_content_store_from_publishing_api_http" {
  description              = "Draft Content Store accepts requests from Publishing API over HTTP"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.draft_content_store.security_group_id
  source_security_group_id = module.publishing_api_web.security_group_id
}

resource "aws_security_group_rule" "content_store_from_frontend_http" {
  description              = "Content Store accepts requests from Frontend over HTTP"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.content_store.security_group_id
  source_security_group_id = module.frontend.app_security_group_id
}

resource "aws_security_group_rule" "draft_content_store_from_frontend_http" {
  description              = "Draft Content Store accepts requests from Draft Frontend over HTTP"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.draft_content_store.security_group_id
  source_security_group_id = module.draft_frontend.app_security_group_id
}

# TODO: fix overly broad egress rules
resource "aws_security_group_rule" "content_store_to_any_any" {
  description       = "Content Store sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.content_store.security_group_id
}

resource "aws_security_group_rule" "publisher_to_any_any" {
  description       = "Publisher sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.publisher.app_security_group_id
}

resource "aws_security_group_rule" "redis_from_publisher_resp" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = module.shared_redis_cluster.security_group_id
  source_security_group_id = module.publisher.app_security_group_id
}

resource "aws_security_group_rule" "postgres_from_publishing_api_5432" {
  description = "Postgres RDS accepts requests from Publishing API"
  type        = "ingress"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"

  security_group_id        = local.postgresql_security_group_id
  source_security_group_id = module.publishing_api_web.security_group_id
}

resource "aws_security_group_rule" "redis_from_publishing_api_resp" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = module.shared_redis_cluster.security_group_id
  source_security_group_id = module.publishing_api_web.security_group_id
}

resource "aws_security_group_rule" "documentdb_from_publisher_mongodb" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = local.documentdb_security_group_id
  source_security_group_id = module.publisher.app_security_group_id
}

resource "aws_security_group_rule" "publishing_api_from_publisher_http" {
  description = "Publishing API accepts requests from Publisher over HTTP"
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"

  security_group_id        = module.publishing_api_web.security_group_id
  source_security_group_id = module.publisher.app_security_group_id
}

resource "aws_security_group_rule" "publishing_api_from_frontend_http" {
  description = "Publishing API accepts requests from Frontend over HTTP"
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"

  security_group_id        = module.publishing_api_web.security_group_id
  source_security_group_id = module.frontend.app_security_group_id
}

resource "aws_security_group_rule" "frontend_to_any_any" {
  description       = "Frontend sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.frontend.app_security_group_id
}

resource "aws_security_group_rule" "draft_frontend_to_any_any" {
  description       = "Draft Frontend sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.draft_frontend.app_security_group_id
}

data "aws_nat_gateway" "govuk" {
  count     = length(local.public_subnets)
  subnet_id = local.public_subnets[count.index]
}

resource "aws_security_group_rule" "frontend_alb_from_test_nat_gateways_https" {
  description = "Frontend ALB receives HTTPS requests from apps in ECS"
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"

  security_group_id = module.frontend.alb_security_group_id
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
  security_group_id = module.static.app_security_group_id
}

resource "aws_security_group_rule" "static_from_frontend_http" {
  description              = "Static receives requests from Frontend over HTTP"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.static.app_security_group_id
  source_security_group_id = module.frontend.app_security_group_id
}

resource "aws_security_group_rule" "draft_static_to_any_any" {
  description       = "Draft Static sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.draft_static.app_security_group_id
}

resource "aws_security_group_rule" "draft_static_from_frontend_http" {
  description              = "Draft Static receives requests from Draft Frontend over HTTP"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.draft_static.app_security_group_id
  source_security_group_id = module.draft_frontend.app_security_group_id
}

resource "aws_security_group_rule" "mongodb_from_content_store_mongodb" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = local.mongodb_security_group_id
  source_security_group_id = module.content_store.security_group_id
}

resource "aws_security_group_rule" "mongodb_from_draft_content_store_mongodb" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = local.mongodb_security_group_id
  source_security_group_id = module.draft_content_store.security_group_id
}

resource "aws_security_group_rule" "router_api_from_content_store_http" {
  description = "Router API accepts requests from Content Store over HTTP"
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"

  security_group_id        = module.router_api.security_group_id
  source_security_group_id = module.content_store.security_group_id
}

resource "aws_security_group_rule" "routerdb_from_router_api_mongodb" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = local.routerdb_security_group_id
  source_security_group_id = module.router_api.security_group_id
}

resource "aws_security_group_rule" "routerdb_from_draft_router_api_mongodb" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = local.routerdb_security_group_id
  source_security_group_id = module.draft_router_api.security_group_id
}

resource "aws_security_group_rule" "draft_router_api_from_draft_content_store_http" {
  description = "Draft Router API accepts requests from Draft Content Store over HTTP"
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"

  security_group_id        = module.draft_router_api.security_group_id
  source_security_group_id = module.draft_content_store.security_group_id
}

resource "aws_security_group_rule" "routerdb_from_router_mongodb" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = local.routerdb_security_group_id
  source_security_group_id = module.router.security_group_id
}

resource "aws_security_group_rule" "router_from_router_api_tcp" {
  description = "Router accepts requests from Router API over TCP"
  type        = "ingress"
  from_port   = 3055
  to_port     = 3055
  protocol    = "tcp"

  security_group_id        = module.router.security_group_id
  source_security_group_id = module.router_api.security_group_id
}

resource "aws_security_group_rule" "routerdb_from_draft_router_mongodb" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = local.routerdb_security_group_id
  source_security_group_id = module.draft_router.security_group_id
}

resource "aws_security_group_rule" "draft_router_from_draft_router_api_tcp" {
  description = "Draft Router accepts requests from Draft Router API over TCP"
  type        = "ingress"
  from_port   = 3055
  to_port     = 3055
  protocol    = "tcp"

  security_group_id        = module.draft_router.security_group_id
  source_security_group_id = module.draft_router_api.security_group_id
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
  source_security_group_id = module.signon.security_group_id
}

resource "aws_security_group_rule" "mysql_from_signon_mysql" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = local.mysql_security_group_id
  source_security_group_id = module.signon.security_group_id
}

resource "aws_security_group_rule" "signon_to_any_any" {
  description       = "Signon sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.signon.security_group_id
}

resource "aws_security_group_rule" "statsd_from_apps_tcp" {
  description              = "Allow services in the App Mesh to send metrics to the mesh Statsd via TCP"
  type                     = "ingress"
  from_port                = "8125"
  to_port                  = "8125"
  protocol                 = "tcp"
  security_group_id        = module.statsd.security_group_id
  source_security_group_id = aws_security_group.mesh_ecs_service.id
}

resource "aws_security_group_rule" "mesh_service_to_any_https" {
  description       = "Mesh services send requests to anywhere over HTTPS"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mesh_ecs_service.id
}

resource "aws_security_group_rule" "mesh_service_to_any_dns_tcp" {
  description       = "Mesh services send DNS queries anywhere over TCP"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mesh_ecs_service.id
}

resource "aws_security_group_rule" "mesh_service_to_any_dns_udp" {
  description       = "Mesh services send DNS queries anywhere over UDP"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mesh_ecs_service.id
}

resource "aws_security_group_rule" "mesh_service_to_mesh_service_http" {
  description              = "Mesh services send to requests to other mesh services over HTTP"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.mesh_ecs_service.id
  security_group_id        = aws_security_group.mesh_ecs_service.id
}

resource "aws_security_group_rule" "smoke_test_to_any_https" {
  description       = "Smoke tests can make HTTPS requests anywhere"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.smokey.id
}

resource "aws_security_group_rule" "smoke_test_to_any_http" {
  description       = "Smoke tests can make HTTP requests anywhere"
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.smokey.id
}

# TODO: move the rest of the rules into this file unless there's a good reason
#       for them to stay in other files.
