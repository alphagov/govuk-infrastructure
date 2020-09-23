output "ingress_security_group" {
  value       = aws_security_group.service.id
  description = "Add ingress rules to this security group to permit another service to communicate with content-store"
}
