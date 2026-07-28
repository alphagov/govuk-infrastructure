# remember any kind used by a constraint template must also be added to the sync config at the end of this file
resource "kubectl_manifest" "constraint_templates" {
  for_each = fileset("${path.module}/../resources/constraint_templates/", "*")

  wait      = true
  yaml_body = file("${path.module}/../resources/constraint_templates/${each.value}")
}
