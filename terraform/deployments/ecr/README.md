# Elastic Container Registry for GOV.UK in Kubernetes

Container images for GOV.UK on Kubernetes are stored in AWS ECR. The registry
is hosted in the GOV.UK production AWS account.

All accounts/environments use the **production** ECR. This is because there
would be no real benefit to having multiple registries but considerable
complexity in copying images around between registries.

There is also a test registry in the test AWS account. This is intended for
testing changes to the configuration of ECR itself or changes to this Terraform
module, for example IAM permissions changes or nontrivial changes to repository
settings.

You can manually add an ECR registry, but if you're using an alphagov-owned
GitHub repository (e.g. alphagov/whitehall) a registry will be created for
the repository automatically.

## Applying Terraform

Please only deploy this module in the `test` and `production` accounts, not
integration or staging.

You must generate a GITHUB_TOKEN with the `repo` permission to use this module.

```shell
# Test registry (for testing this module or changes to the registry config)

GITHUB_TOKEN=<generate-personal-access-token>

gds aws govuk-test-admin -- \
  terraform init -backend-config test.backend -reconfigure -upgrade

gds aws govuk-test-admin -- \
  terraform apply -var-file ../variables/test/ecr.tfvars


# Production registry (for use by all clusters/environments including test)

gds aws govuk-production-admin -- \
  terraform init -backend-config production.backend -reconfigure -upgrade

gds aws govuk-production-admin -- \
  terraform apply -var-file ../variables/production/ecr.tfvars
```
