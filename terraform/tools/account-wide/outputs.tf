output "logging_bucket" {
  description = "Centralised AWS S3 bucket for logging"
  value       = module.logging_bucket
}

output "state_files_bucket" {
  description = "Centralised terraform state files bucket for all accounts"
  value       = module.state_file_bucket
}
