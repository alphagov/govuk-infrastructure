terraform {
  required_providers {
    terraform = {
      source = "terraform.io/builtin/terraform"
    }
  }
}

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
  value           = provider::terraform::encode_expr(each.value)
  hcl             = true
  category        = "terraform"
}
