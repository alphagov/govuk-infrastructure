output "project" {
  description = "The entire google_project resource object."
  value       = google_project.project
}

output "iam_binding_project_owners" {
  description = "The project's IAM binding for roles/owner"
  value       = google_project_iam_binding.project_owners
}

output "iam_binding_project_editors" {
  description = "The project's IAM binding for roles/editor"
  value       = google_project_iam_binding.project_editors
}

output "iam_binding_project_viewers" {
  description = "The project's IAM binding for roles/viewer"
  value       = google_project_iam_binding.project_viewers
}
