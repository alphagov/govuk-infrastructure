output "json" {
  description = "The IAM policy document, as JSON, granting the permissions needed to plan and apply GOV.UK Terraform"
  value       = data.aws_iam_policy_document.this.json
}
