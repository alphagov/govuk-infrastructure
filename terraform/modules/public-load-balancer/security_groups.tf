resource "aws_security_group" "public_alb" {
  name        = "fargate_${var.app_name}_${var.workspace_suffix}_public_alb"
  vpc_id      = var.vpc_id
  description = "${var.app_name} Internet-facing ALB in ${var.workspace_suffix} cluster"
}

resource "aws_security_group_rule" "service_from_alb_http" {
  description              = "${var.app_name} receives requests from its public ALB over HTTP"
  type                     = "ingress"
  from_port                = var.target_port
  to_port                  = var.target_port
  protocol                 = "tcp"
  security_group_id        = var.service_security_group_id
  source_security_group_id = aws_security_group.public_alb.id
}

resource "aws_security_group_rule" "alb_from_any_https" {
  description       = "${var.app_name} ALB allows requests from CIDRs list over HTTPS"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.external_cidrs_list
  security_group_id = aws_security_group.public_alb.id
}

resource "aws_security_group_rule" "alb_to_any_any" {
  type      = "egress"
  protocol  = "-1"
  from_port = 0
  to_port   = 0

  security_group_id = aws_security_group.public_alb.id
  cidr_blocks       = ["0.0.0.0/0"]
}
