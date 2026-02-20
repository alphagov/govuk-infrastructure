# Shared Terraform modules

We offer a library of Terraform modules that we encourage our users to make use of when creating common collections of Terraform resources. The motivation for creating these modules is to encourage best practices and to make creating Terraform easier and cleaner for our users.

When using our modules be sure to pin the source reference to the latest commit hash, for example:

```
module "secure_s3_bucket" {
  source = "github.com/alphagov/govuk-infrastructure/terraform/shared-modules/s3?ref=3f260111d76ce69eeb1f6b9b8d3ea52e1bd467b4"

  name               = local.bucket_name
  versioning_enabled = true
  lifecycle_rules    = []
}
```

The shared modules are in [the `terraform/shared-modules` directory](https://github.com/alphagov/govuk-infrastructure/tree/main/terraform/shared-modules) in this repository.
