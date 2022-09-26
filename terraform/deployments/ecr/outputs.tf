output "push_to_ecr_role_arn" {
  description = "ARN of the push to ECR role"
  value       = aws_iam_role.push_to_ecr.arn
}
