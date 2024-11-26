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
  value       = { for k, v in aws_security_group.rds : k => v.id }
}
