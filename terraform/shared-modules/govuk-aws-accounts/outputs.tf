output "account_name_to_id" {
  description = "A map with account names as keys and account IDs as valus"
  value       = local.account_name_to_id
}

output "account_id_to_name" {
  description = "A map with account IDs as keys and account names as values"
  value       = local.account_id_to_name
}

output "account_ids" {
  description = "A list of all account IDs"
  value       = local.account_ids
}

output "account_names" {
  description = "A list of all account names"
  value       = local.account_names
}
