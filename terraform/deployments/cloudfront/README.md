# GOV.UK Failover CloudFront CDN

This module configures the CloudFront CDN to be used for failover in the event of a Fastly outage.

## Applying Terraform

1. Configure Terraform
    ```shell
    gds aws govuk-<environment>-poweruser -- terraform init -backend-config <environment>.backend -upgrade -reconfigure
    ```
2. Plan Terraform
    ```shell
    gds aws govuk-<environment>-poweruser -- terraform plan -var-file ../variables/common.tfvars -var-file ../variables/<environment>/common.tfvars -var-file ../variables/<environment>/cloudfront.tfvars
    ```
3. Apply Terraform
    ```shell
    gds aws govuk-<environment>-poweruser -- terraform apply -var-file ../variables/common.tfvars -var-file ../variables/<environment>/common.tfvars -var-file ../variables/<environment>/cloudfront.tfvars
    ```
