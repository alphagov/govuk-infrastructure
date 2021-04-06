variable "restricted_path_patterns" {
  type        = list(string)
  description = "Patterns for paths to restrict to fully_trusted_source_ips"
}

variable "fully_trusted_source_ips" {
  type        = list(string)
  description = "IPs which can access restricted_path_patterns"
}

variable "aws_lb_listener_arn" {
  type        = string
  description = "LB listener to apply rules to"
}

variable "aws_lb_target_group_arn" {
  type        = string
  description = "Target group that the listener forwards requests to"
}
