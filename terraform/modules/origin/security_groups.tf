resource "aws_security_group" "origin_alb" {
  name        = "fargate_${local.live_or_draft_prefix}_origin_${var.workspace}_alb"
  vpc_id      = var.vpc_id
  description = "${local.live_or_draft_prefix}-origin Internet-facing ALB in govuk-${var.workspace} cluster"
}

# TODO: Move rules to deployments/govuk-publishing-platform/security_group_rules
resource "aws_security_group_rule" "service_from_origin_alb_http" {
  for_each                 = var.apps_security_config_list
  description              = "${each.key} receives requests from the ${local.live_or_draft_prefix}-origin-${var.workspace} ALB over HTTP"
  type                     = "ingress"
  from_port                = each.value.target_port
  to_port                  = each.value.target_port
  protocol                 = "tcp"
  security_group_id        = each.value.security_group_id
  source_security_group_id = aws_security_group.origin_alb.id
}

resource "aws_security_group_rule" "origin_alb_from_cidrs_https" {
  description = "${local.live_or_draft_prefix}-origin-${var.workspace} ALB allows requests from CIDRs list over HTTPS"
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  # We use a secret custom header to authenticate requests via the origin ALB
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.origin_alb.id
}

resource "aws_security_group_rule" "origin_alb_to_any_any" {
  type      = "egress"
  protocol  = "-1"
  from_port = 0
  to_port   = 0

  security_group_id = aws_security_group.origin_alb.id
  cidr_blocks       = ["0.0.0.0/0"]
}
