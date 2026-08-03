# search-api-v2
This Terraform module is for ongoing maintenance of the search GCP projects. It includes
set up of Discovery Engine resources, service accounts and keys, and AWS Secrets Manager secrets
consumed by the Kubernetes platform for an individual environment (integration, staging and production) for
[`search-api-v2`][search-api-v2-repo].

## Related infrastructure

For initial (bootstrapping) setup of the GCP projects, including broad access roles, see [gcp-search-api-v2][gcp-search-api-v2-deployment].

The setup of the Terraform workspaces for this module is done in the [tfc-configurations][search-v2-tfc-config]. 

## Applying this module
This module will automatically be **planned** across all environments in [Terraform Cloud][terraform-cloud] on
merges to the `main` branch. The module will also be automatically **applied** in integration and staging, but
needs to be manually applied in production.

## Setting variables
To set variables that change depending on the environment, the variables should be defined in [variables.tf][variables]
and set in the relevant search-api-v2.tfvars files for each environment in the [variables folder][variables-folder].

## Resources
This module provisions the following resources into the Google Cloud Platform project specified:
- A Discovery Engine datastore and schema
- Discovery Engine serving configurations and controls
- Configuration for Autocomplete
- BigQuery Dataform pipelines to process data relevant to Discovery Engine
- Two service accounts with respective roles and keys to access Discovery Engine from a consuming application
- Read-only service accounts for local development
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
[gcp-search-api-v2-deployment]: ../gcp-search-api-v2/
[search-v2-tfc-config]: ../tfc-configuration/search-api-v2.tf
[variables]: ./variables.tf
[variables-folder]: ../../variables