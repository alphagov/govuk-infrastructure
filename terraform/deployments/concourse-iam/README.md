# Concourse IAM

Enables Concourse pipelines to make changes in an AWS account, e.g. to deploy.

Apply once per GOV.UK environment.

## Applying

```shell
terraform apply -var-file=../variables/<govuk_environment>/iam.tfvars
```
