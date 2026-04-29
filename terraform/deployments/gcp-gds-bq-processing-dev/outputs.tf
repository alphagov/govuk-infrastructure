output "project_id" {
  value = module.managed_project.project.project_id
}

output "project_owner_members" {
  value = module.managed_project.iam_binding_project_owners.members
}

output "project_editor_members" {
  value = module.managed_project.iam_binding_project_editors.members
}

output "project_viewer_members" {
  value = module.managed_project.iam_binding_project_viewers.members
}
