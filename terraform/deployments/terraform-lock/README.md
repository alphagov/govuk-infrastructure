# Terraform state lock

This provides [DynamoDB State Locking][] for other Terraform deployments. It should
usually be the first Terraform deployment you apply when bringing up the
infrastructure in a new AWS account.

A DynamoDB table is created in each GOV.UK environment for Terraform locking.


## Applying

Applying:

```sh
terraform init -backend-config=./<govuk_environment>.backend
terraform apply
```

where:
`<govuk_environment>` is the GOV.UK environment where you want the changes to be
applied.

This creates a table `terraform-lock`.

The table is then used by the S3 backend of `govuk-publishing-platform`,
in the backend config `dynamodb_table = "terraform-lock"`.

State locking happens automatically.
See the docs for more detail: https://www.terraform.io/docs/language/state/locking.html

[DynamoDB State Locking]: https://www.terraform.io/docs/language/settings/backends/s3.html#dynamodb-state-locking
