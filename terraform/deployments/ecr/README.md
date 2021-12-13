# Elastic Container Registry for GOV.UK in Kubernetes

Container images for GOV.UK on Kubernetes are stored in AWS ECR. The registry is hosted in the GOV.UK production AWS account. There is also a test registry (for example for testing IAM changes to the registry itself) in the test AWS account.

## Applying Terraform

```shell
# Test registry (for testing changes to the registry config)

gds aws govuk-test-admin -- \
  terraform init -backend-config test.backend -upgrade

gds aws govuk-test-admin -- \
  terraform apply -var-file ../variables/test/ecr.tfvars


# Production registry (for use by all environments)

gds aws govuk-production-admin -- \
  terraform init -backend-config production.backend -upgrade

gds aws govuk-production-admin -- \
  terraform apply -var-file ../variables/production/ecr.tfvars
```
