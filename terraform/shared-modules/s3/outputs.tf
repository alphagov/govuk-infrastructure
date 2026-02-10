output "name" {
  value = aws_s3_bucket.this.id
}

output "arn" {
  value = aws_s3_bucket.this.arn
}

output "irsa_policy_arn" {
  description = "IAM policy ARN for access to the S3 bucket"
  value       = aws_iam_policy.this.arn
}
