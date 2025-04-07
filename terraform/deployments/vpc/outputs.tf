output "id" { value = aws_vpc.vpc.id }

output "private_subnet_ids" {
  description = "A map of private subnet names to IDs"
  value       = { for name, subnet in var.legacy_private_subnets : name => aws_subnet.private_subnet[name].id }
}

output "public_subnet_ids" {
  description = "A map of public subnet names to IDs"
  value       = { for name, subnet in var.legacy_public_subnets : name => aws_subnet.public_subnet[name].id }
}

output "internet_gateway_id" {
  value = aws_internet_gateway.public.id
}
