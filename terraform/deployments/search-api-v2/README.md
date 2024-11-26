# environment
Set up Discovery Engine resources, service accounts and keys, and AWS Secrets Manager secrets
consumed by the Kubernetes platform for an individual environment (e.g. integration, production) for
[`search-api-v2`][search-api-v2-repo] (applied once per environment through Terraform Cloud)

## Terraform Cloud
This module will automatically be planned and applied in [Terraform Cloud][terraform-cloud] on
merges to the `main` branch.

## Resources
This module provisions the following resources into the Google Cloud Platform project specified:
- A Discovery Engine datastore and schema
- Two service accounts with respective roles (read and write) and keys to access Discovery Engine
  from a consuming application
- AWS Secrets Manager secrets to be consumed by the API service application in the corresponding
  environment on the Kubernetes platform

> **Note**
> The Discovery Engine resources are managed through the [RestAPI provider][restapi_provider_docs]
> due to the Google provider not offering first party Terraform resources yet (as of October 2023).

> **Warning**
> As of October 2023, the Google Discovery Engine API has a _manual_ enabling step that can only be
> done [through the GCP console][enable-de]. This only needs doing once after initial project
> creation, but the datastore creation (or any other Discovery Engine API calls) will fail until
> then.

[enable-de]: https://console.cloud.google.com/gen-app-builder/start
[restapi_provider_docs]: https://registry.terraform.io/providers/Mastercard/restapi/latest
[search-api-v2-repo]: https://github.com/alphagov/search-api-v2
[terraform-cloud]: https://app.terraform.io/
