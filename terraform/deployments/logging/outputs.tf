output "aws_logging_bucket_id" {
  value       = module.aws_logging_bucket.name
  description = "Name of the AWS logging bucket"
}

output "aws_logging_bucket_arn" {
  value       = module.aws_logging_bucket.arn
  description = "ARN of the AWS logging bucket"
}

output "rds_enhanced_monitoring_role_arn" {
  description = "The ARN of the IAM role for RDS Enhanced Monitoring"
  value       = aws_iam_role.rds_enhanced_monitoring.arn
}
