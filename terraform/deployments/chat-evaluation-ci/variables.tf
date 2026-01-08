variable "aws_region" {
  type        = string
  description = "AWS region to target for Bedrock model ARN and provider configuration."
  default     = "eu-west-1"
}

variable "govuk_environment" {
  type        = string
  description = "GOV.UK environment/account target. This root is intended for the test account."
  default     = "test"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository allowed to assume the Bedrock CI role, in OWNER/REPO form."
  default     = "alphagov/govuk-chat-evaluation"
}

variable "role_name" {
  type        = string
  description = "Name of IAM role assumed by GitHub Actions to run Bedrock tests."
  default     = "github_action_govuk_chat_evaluation_bedrock_ci"
}

variable "bedrock_model_ids" {
  type        = list(string)
  description = "Bedrock foundation model IDs allowed for invocation."
  default     = ["openai.gpt-oss-120b-1:0"]
}
