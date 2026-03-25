variable "project_id" { type = string }

variable "notification_email_address" {
  type      = string
  sensitive = true
}
