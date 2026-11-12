# Terraform runner policy

A data-only module providing the IAM policy document that grants the
permissions needed to plan and apply GOV.UK Terraform in an AWS account.

It is the single source of truth for those permissions, so that every role
used to run Terraform (for example `terraform-cloud` and the Concourse runner
roles) has the same permission set.

The module does not create any resources. Callers create their own
`aws_iam_policy` from the JSON output, so that each runner keeps its own
policy name and lifecycle.

## Example usage

See [./USAGE.md](./USAGE.md) for a detailed reference.

```tf
module "terraform_runner_policy" {
  source = "../../shared-modules/terraform-runner-policy"
}

resource "aws_iam_policy" "runner" {
  name   = "my-runner"
  policy = module.terraform_runner_policy.json
}
```
