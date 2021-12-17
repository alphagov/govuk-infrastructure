# Terraform state lock

This provides [DynamoDB State Locking] for the other Terraform root modules
under `terraform/deployments`. It should be the first module to apply when
bringing up the infrastructure in a new AWS account.

Each GOV.UK AWS account (environment) has a table called `terraform-lock`.

The table is created by this module and then referred to by the other root
modules with the line `dynamodb_table = "terraform-lock"` in their backend
config files (`*.backend`).

State locking happens automatically. See [State
Locking](https://www.terraform.io/docs/language/state/locking.html) in the
Terraform docs for more detail.


## Applying

```sh
terraform init -backend-config=<environment>.backend -upgrade
terraform apply
```

where `<environment>` is the GOV.UK environment where you want to apply the
changes.

[DynamoDB State Locking]: https://www.terraform.io/docs/language/settings/backends/s3.html#dynamodb-state-locking
