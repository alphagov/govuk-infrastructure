# GOV.UK AWS ECR

In the new platform, container images are stored in AWS ECR. The AWS account
that has been chosen to host the ECR is the GOV.UK production one

## Applying

```shell
gds aws govuk-production-admin -- terraform apply \
 -var-file ../variables/common.tfvars
```
