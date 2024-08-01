variable "hosted_zone_name" { type = string }
variable "security_options_enabled" { type = bool }
variable "volume_type" {
  type = string
}
variable "throughput" {
  type = number
}
variable "ebs_enabled" {
  type = bool
}
variable "ebs_volume_size" {
  type = number
}
variable "service" { type = string }
variable "instance_type" { type = string }
variable "instance_count" { type = number }
variable "dedicated_master_enabled" {
  type    = bool
  default = false
}
variable "dedicated_master_count" {
  type    = number
  default = 0
}
variable "dedicated_master_type" {
  type    = string
  default = null
}
variable "zone_awareness_enabled" {
  type    = bool
  default = false
}
variable "engine_version" {
  type = string
}
variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}
variable "govuk_aws_state_bucket" {
  type        = string
  description = "Bucket where govuk-aws state is stored"
}
variable "govuk_environment" {
  type        = string
  description = "Acceptable values are test, integration, staging, production"
}
variable "test_opensearch_url" {
  type        = string
  description = "The public endpoint for chat-engine-test Opensearch cluster"
  default     = "chat-opensearch.test.govuk-internal.digital"
}
