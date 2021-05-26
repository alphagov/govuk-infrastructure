# Concourse IAM

Enables Concourse pipelines to make changes in an AWS account, e.g. to deploy.

Apply once per GOV.UK environment.

## Applying

```shell
terraform init -backend-config <govuk_environment>.backend -reconfigure

terraform apply \
 -var-file ../variables/common.tfvars \
 -var-file ../variables/<govuk_environment>/common.tfvars
```

where:
`<govuk_environment>` is the GOV.UK environment where you want the changes to be
applied.
