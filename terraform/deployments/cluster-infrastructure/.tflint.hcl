plugin "aws" {
  enabled = true
}

config {
  varfile = [
    "../variables/common.tfvars",
    "../variables/test/common.tfvars",
  ]
}

rule "terraform_comment_syntax" { enabled = true }
rule "terraform_deprecated_index" { enabled = true }
rule "terraform_required_providers" { enabled = true }
rule "terraform_standard_module_structure" { enabled = true }
rule "terraform_typed_variables" { enabled = true }
rule "terraform_unused_declarations" { enabled = true }
rule "terraform_unused_required_providers" { enabled = true }
