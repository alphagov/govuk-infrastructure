locals {
  constraint_template_path = "${path.module}/../resources"
}

# remember any kind used by a constraint template must also be added to the sync config in main.tf
resource "kubectl_manifest" "constraint_templates" {
  for_each = fileset("${local.constraint_template_path}/constraint_templates/", "*")

  wait      = true
  yaml_body = file("${local.constraint_template_path}/constraint_templates/${each.value}")
}
