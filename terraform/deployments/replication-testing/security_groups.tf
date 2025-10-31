resource "aws_security_group" "dms" {
  name        = "jfharden-dms"
  description = "DMS replication instances"
  vpc_id      = data.aws_vpc.govuk.id

  tags = {
    Name = "jfharden-dms"
  }
}

resource "aws_vpc_security_group_egress_rule" "dms_to_content_data_api_source" {
  security_group_id            = aws_security_group.dms.id
  referenced_security_group_id = data.aws_security_group.content_data_api_source.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "dms_to_content_data_api_source" {
  security_group_id            = data.aws_security_group.content_data_api_source.id
  referenced_security_group_id = aws_security_group.dms.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}


resource "aws_vpc_security_group_egress_rule" "dms_from_content_data_api_source" {
  security_group_id            = data.aws_security_group.content_data_api_source.id
  referenced_security_group_id = aws_security_group.dms.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "dms_from_content_data_api_source" {
  security_group_id            = aws_security_group.dms.id
  referenced_security_group_id = data.aws_security_group.content_data_api_source.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}


resource "aws_vpc_security_group_egress_rule" "dms_to_content_data_api_target" {
  security_group_id            = aws_security_group.dms.id
  referenced_security_group_id = data.aws_security_group.content_data_api_target.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "dms_to_content_data_api_target" {
  security_group_id            = data.aws_security_group.content_data_api_target.id
  referenced_security_group_id = aws_security_group.dms.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}


resource "aws_vpc_security_group_egress_rule" "dms_from_content_data_api_target" {
  security_group_id            = data.aws_security_group.content_data_api_target.id
  referenced_security_group_id = aws_security_group.dms.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "dms_from_content_data_api_target" {
  security_group_id            = aws_security_group.dms.id
  referenced_security_group_id = data.aws_security_group.content_data_api_target.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "content_data_api_source_to_target" {
  security_group_id            = data.aws_security_group.content_data_api_source.id
  referenced_security_group_id = data.aws_security_group.content_data_api_target.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}


resource "aws_vpc_security_group_ingress_rule" "content_data_api_source_to_target" {
  security_group_id            = data.aws_security_group.content_data_api_target.id
  referenced_security_group_id = data.aws_security_group.content_data_api_source.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "content_data_api_target_to_source" {
  security_group_id            = data.aws_security_group.content_data_api_target.id
  referenced_security_group_id = data.aws_security_group.content_data_api_source.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "content_data_api_target_to_source" {
  security_group_id            = data.aws_security_group.content_data_api_source.id
  referenced_security_group_id = data.aws_security_group.content_data_api_target.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_security_group" "dms_whitehall" {
  name        = "jfharden-dms-whitehall"
  description = "DMS replication instances for whitehall"
  vpc_id      = data.aws_vpc.govuk.id

  tags = {
    Name = "jfharden-dms-whitehall"
  }
}

resource "aws_vpc_security_group_egress_rule" "dms_to_whitehall_source" {
  security_group_id            = aws_security_group.dms_whitehall.id
  referenced_security_group_id = data.aws_security_group.whitehall_source.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "dms_to_whitehall_source" {
  security_group_id            = data.aws_security_group.whitehall_source.id
  referenced_security_group_id = aws_security_group.dms_whitehall.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "dms_to_whitehall_target" {
  security_group_id            = aws_security_group.dms_whitehall.id
  referenced_security_group_id = data.aws_security_group.whitehall_target.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "dms_to_whitehall_target" {
  security_group_id            = data.aws_security_group.whitehall_target.id
  referenced_security_group_id = aws_security_group.dms_whitehall.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "whitehall_target_to_source" {
  security_group_id            = data.aws_security_group.whitehall_target.id
  referenced_security_group_id = data.aws_security_group.whitehall_source.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "whitehall_target_to_source" {
  security_group_id            = data.aws_security_group.whitehall_source.id
  referenced_security_group_id = data.aws_security_group.whitehall_target.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}
