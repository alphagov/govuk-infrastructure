resource "aws_security_group" "origin_alb" {
  name        = "fargate_${local.mode}_origin_${var.workspace}_alb"
  vpc_id      = var.vpc_id
  description = "${local.mode}-origin Internet-facing ALB in ${var.workspace} cluster"
}

resource "aws_security_group_rule" "service_from_origin_alb_http" {
  for_each                 = var.apps_security_config_list
  description              = "${each.key} receives requests from the ${local.mode}-origin ALB over HTTP"
  type                     = "ingress"
  from_port                = each.value.target_port
  to_port                  = each.value.target_port
  protocol                 = "tcp"
  security_group_id        = each.value.security_group_id
  source_security_group_id = aws_security_group.origin_alb.id
}

resource "aws_security_group_rule" "origin_alb_from_any_https" {
  description       = "${local.mode}-origin ALB allows requests from CIDRs list over HTTPS"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.external_cidrs_list
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
