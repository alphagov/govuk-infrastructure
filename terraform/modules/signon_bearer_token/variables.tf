variable "app_name" {
  type        = string
  description = "Workspace-aware name for a Signon OAuth application resource, e.g. Publishing API"
}

variable "aws_lambda_function_arn" {
  type        = string
  description = "SecretsManager Rotation Lambda ARN"
}

variable "name" {
  type = string
}

variable "workspace" {
  type = string
}

variable "environment" {
  type = string
}

variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}
