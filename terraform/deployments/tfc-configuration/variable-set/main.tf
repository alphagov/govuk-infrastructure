resource "tfe_variable_set" "set" {
  name         = var.name
  organization = "govuk"
  priority     = var.priority
  global       = false
}

resource "tfe_variable" "vars" {
  for_each = var.tfvars

  variable_set_id = tfe_variable_set.set.id
  key             = each.key
  value           = try(tostring(each.value), "nostring") == "nostring" ? replace(jsonencode(each.value), ":", "=") : tostring(each.value)
  hcl             = try(tostring(each.value), "nostring") == "nostring" ? true : false
  category        = "terraform"
}
