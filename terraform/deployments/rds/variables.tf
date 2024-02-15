variable "govuk_environment" {
  type        = string
  description = "Environment name"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "stackname" {
  type        = string
  description = "Stackname"
  default     = "blue"
}

variable "govuk_aws_state_bucket" {
  type        = string
  description = "Bucket where govuk-aws state is stored"
}

variable "remote_state_infra_monitoring_key_stack" {
  type        = string
  description = "Override path to infra_monitoring remote state"
  default     = "govuk"
}

variable "remote_state_infra_networking_key_stack" {
  type        = string
  description = "Override path to infra_networking remote state"
  default     = "govuk"
}

variable "remote_state_infra_root_dns_zones_key_stack" {
  type        = string
  description = "Override path to infra_root_dns_zones remote state"
  default     = "govuk"
}

variable "remote_state_infra_vpc_key_stack" {
  type        = string
  description = "Override path to infra_vpc remote state"
  default     = "govuk"
}

variable "databases" {
  type        = map(any)
  description = "Databases to create and their configuration."
}

variable "database_admin_username" {
  type        = string
  default     = "aws_db_admin"
  description = "RDS root account username."
}

variable "multi_az" {
  type        = bool
  description = "Set to true to deploy the RDS instance in multiple AZs."
  default     = false
}

variable "maintenance_window" {
  type        = string
  description = "The window to perform maintenance in"
  default     = "Mon:04:00-Mon:06:00"
}

variable "backup_window" {
  type        = string
  description = "The daily time range during which automated backups are created if automated backups are enabled."
  default     = "01:00-03:00"
}

variable "backup_retention_period" {
  type        = number
  description = "Backup retention period in days."
  default     = 7
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Set to true to NOT create a final snapshot when the cluster is deleted."
  default     = false
}

variable "terraform_create_rds_timeout" {
  type        = string
  description = "Set the timeout time for AWS RDS creation."
  default     = "2h"
}

variable "terraform_update_rds_timeout" {
  type        = string
  description = "Set the timeout time for AWS RDS modification."
  default     = "2h"
}

variable "terraform_delete_rds_timeout" {
  type        = string
  description = "Set the timeout time for AWS RDS deletion."
  default     = "2h"
}

variable "internal_zone_name" {
  type        = string
  description = "The name of the Route53 zone that contains internal records"
}

variable "internal_domain_name" {
  type        = string
  description = "The domain name of the internal DNS records, it could be different from the zone name"
}
