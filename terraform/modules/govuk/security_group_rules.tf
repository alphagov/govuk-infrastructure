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
  security_group_id        = var.redis_security_group_id
  source_security_group_id = module.publisher_service.app_security_group_id
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

# TODO: move the rest of the rules into this file.
