resource "aws_db_parameter_group" "release_mysql_84_green_params" {
  name_prefix = "release-mysql-84-temp-"

  family = "mysql8.4"

  parameter {
    name         = "max_allowed_packet"
    value        = 1073741824
    apply_method = "pending-reboot"
  }
}
