output "rds_instance_id" {
  description = "RDS instance IDs"
  value       = { for k, v in aws_db_instance.instance : k => v.id }
}

output "rds_resource_id" {
  description = "RDS instance resource IDs"
  value       = { for k, v in aws_db_instance.instance : k => v.resource_id }
}

output "rds_endpoint" {
  description = "RDS instance endpoints"
  value       = { for k, v in aws_db_instance.instance : k => v.endpoint }
}

output "rds_address" {
  description = "RDS instance addresses"
  value       = { for k, v in aws_db_instance.instance : k => v.address }
}

output "sg_rds" {
  description = "RDS instance security groups"
  value       = { for k, v in aws_security_group.instance : k => v.id }
}

output "database_dump_bucket_arn" {
  description = "The ARN of the AWS S3 bucket that is created to hold database backups. If the bucket is not created, this value is the empty string"
  value       = var.create_secure_db_dumps_bucket ? module.secure_s3_bucket_rds_dumps[0].arn : ""
}
