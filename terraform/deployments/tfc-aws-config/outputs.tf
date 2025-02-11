output "aws_credentials_id" {
  value = tfe_variable_set.variable_set.id
}

output "aws_credentials_name" {
  value = tfe_variable_set.variable_set.name
}

output "gcp_credentials_id" {
  value = tfe_variable_set.gcp_variable_set.id
}

output "gcp_credentials_name" {
  value = tfe_variable_set.gcp_variable_set.name
}
