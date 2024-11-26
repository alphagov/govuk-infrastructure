#
# == Manifest: Project: Security Groups: rabbitmq
#
# The rabbitmq needs to be accessible on ports:
#   - 5672/tcp
#
# === Variables:
# stackname - string
#
# === Outputs:
# sg_rabbitmq_id
# sg_rabbitmq_elb_id

resource "aws_security_group" "rabbitmq" {
  name        = "govuk_rabbitmq_access"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id
  description = "Access to the rabbitmq host from its ELB"
}

data "aws_security_group" "rabbitmq" {
  name = "govuk_rabbitmq_access"
}

import {
  to = aws_security_group.rabbitmq
  id = data.aws_security_group.rabbitmq.id
}

resource "aws_security_group_rule" "rabbitmq_ingress_rabbitmq_elb_amqp" {
  type      = "ingress"
  from_port = 5672
  to_port   = 5672
  protocol  = "tcp"

  # Which security group is the rule assigned to
  security_group_id = aws_security_group.rabbitmq.id

  # Which security group can use this rule
  source_security_group_id = aws_security_group.rabbitmq_elb.id
}

resource "aws_security_group_rule" "rabbitmq_ingress_rabbitmq_elb_stomp" {
  type      = "ingress"
  from_port = 6163
  to_port   = 6163
  protocol  = "tcp"

  # Which security group is the rule assigned to
  security_group_id = aws_security_group.rabbitmq.id

  # Which security group can use this rule
  source_security_group_id = aws_security_group.rabbitmq_elb.id
}

resource "aws_security_group_rule" "rabbitmq_ingress_rabbitmq_transport" {
  type      = "ingress"
  from_port = 9100
  to_port   = 9100
  protocol  = "tcp"

  # Which security group is the rule assigned to
  security_group_id = aws_security_group.rabbitmq.id

  # Which security group can use this rule
  source_security_group_id = aws_security_group.rabbitmq.id
}

resource "aws_security_group_rule" "rabbitmq_ingress_rabbitmq_epmd" {
  type      = "ingress"
  from_port = 4369
  to_port   = 4369
  protocol  = "tcp"

  # Which security group is the rule assigned to
  security_group_id = aws_security_group.rabbitmq.id

  # Which security group can use this rule
  source_security_group_id = aws_security_group.rabbitmq.id
}

resource "aws_security_group" "rabbitmq_elb" {
  name        = "rabbitmq-elb-access"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id
  description = "Access the rabbitmq Internal ELB"
}

resource "aws_security_group_rule" "rabbitmq_elb_egress_any_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rabbitmq_elb.id
}

resource "aws_security_group_rule" "publishingamazonmq_ingress_lb_https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  description = "LB healthchecks to Publishing AmazonMQ"

  security_group_id = aws_security_group.rabbitmq.id
  cidr_blocks       = data.aws_subnet.lb_subnets[*].cidr_block
}

resource "aws_security_group_rule" "publishingamazonmq_ingress_lb_amqps" {
  type        = "ingress"
  from_port   = 5671
  to_port     = 5671
  protocol    = "tcp"
  description = "AMQPS ingress for Publishing AmazonMQ"

  security_group_id = aws_security_group.rabbitmq.id
  cidr_blocks       = data.aws_subnet.lb_subnets[*].cidr_block
}

resource "aws_security_group_rule" "rabbitmq_egress_self_self" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  source_security_group_id = aws_security_group.rabbitmq.id
  security_group_id        = aws_security_group.rabbitmq.id
}
