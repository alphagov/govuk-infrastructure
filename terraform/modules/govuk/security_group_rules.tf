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
  from_port                = "80"
  to_port                  = "80"
  protocol                 = "tcp"
  security_group_id        = module.content_store_service.security_group_id
  source_security_group_id = module.publishing_api_service.security_group_id
}

# TODO: fix overly broad egress rule
resource "aws_security_group_rule" "content_store_to_any_any" {
  description       = "Content Store sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.content_store_service.security_group_id
}

# TODO: move the rest of the rules into this file.
