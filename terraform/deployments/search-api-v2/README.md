# search-api-v2
This Terraform module is for ongoing maintenance of the search GCP projects. It includes
set up of Discovery Engine resources, service accounts and keys, and AWS Secrets Manager secrets
consumed by the Kubernetes platform for an individual environment (integration, staging and production) for
[`search-api-v2`][search-api-v2-repo].

## Related infrastructure

For initial (bootstrapping) setup of the GCP projects, including broad access roles, see [gcp-search-api-v2][gcp-search-api-v2-deployment].

The setup of the Terraform workspaces for this module is done in the [tfc-configurations][search-v2-tfc-config].

For managing AWS resources related to search, including for the [search API gateway][api-gateway] and `search-api-v1`, see [govuk-publishing-infrastructure][publishing-deployment].

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

## Additional information
### Quotas and system limits
Our usage of the various Google APIs is controlled through [quotas and system limits][quotas-and-system-limits]. Quota changes can be agreed with Google through [quota preferences](#quota-preferences) or capped using [quota overrides](#quota-overrides), while system limits are fixed. 

Despite its fixed nature we have agreed an increase to the system limit `SearchRequestsPerMinutePerProjectPerRegion` on `production`. Quotas and system limits can be found in the GCP console under "IAM and Admin > Quotas and system limits".

### Quota preferences
[Quota preferences][quota_preference] are used to request changes to quota values and to document changes already agreed with Google. Note that they cannot be used to alter system limits.

### Quota overrides
Quota overrides are used to cap limits below values that have been set by default or by admin/producer overrides.
On GCP, these are somewhat complex to set up and use inconsistent terminology between the
console UI, the REST API, and the (beta) Terraform provider. In particular, it can be somewhat
confusing to figure out the `limit` value for the `google_service_usage_consumer_quota_override`
resource (which actually corresponds to the `unit` field in the API but with different syntax), and
to find the internal (not display) name of quotas.

If you need to set up a new `google_service_usage_consumer_quota_override` resource for a Discovery
Engine project, the best way of finding out these values is to make a GET request to the
`consumerQuotaMetrics` endpoint like so:

```bash
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
-H "Content-Type: application/json" \
"https://serviceusage.googleapis.com/v1beta1/projects/${GCP_PROJECT}/services/discoveryengine.googleapis.com/consumerQuotaMetrics" \
| jq -r '.metrics[] | "\(.displayName): \(.consumerQuotaLimits[0].metric) (\(.consumerQuotaLimits[0].unit | gsub("[1\\{\\}]";"")))"' \
| sort
```

This returns a list of available quotas by display name, complete with the necessary `metric` and
`unit` values.

There are limits on the Google side on how high we are permitted to set quotas. If
you attempt to increase them beyond the ceiling, a `COMMON_QUOTA_CONSUMER_OVERRIDE_TOO_HIGH`
error will be raised (including some metadata that should tell you what the current ceiling is).
You will need to request a quota increase from Google via the Cloud Quotas API using [quota_preferences](#quota-preferences) first.

> **Note**
> The Discovery Engine resources are managed through the [RestAPI provider][restapi_provider_docs]
> due to the Google provider not offering sufficient first party Terraform resources yet (as of August 2026).
> The Google provider does offer a [first party resource for serving controls][control_resource],
> but this doesn't support multiple control points for boost actions at this point, so doesn't meet our needs.

> **Warning**
> As of October 2023, the Google Discovery Engine API has a _manual_ enabling step that can only be
> done [through the GCP console][enable-de]. This only needs doing once after initial project
> creation, but the datastore creation (or any other Discovery Engine API calls) will fail until
> then.

[enable-de]: https://console.cloud.google.com/gen-app-builder/start
[restapi_provider_docs]: https://registry.terraform.io/providers/Mastercard/restapi/latest
[control_resource]: https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/discovery_engine_control
[search-api-v2-repo]: https://github.com/alphagov/search-api-v2
[terraform-cloud]: https://app.terraform.io/
[api-gateway]: ../govuk-publishing-infrastructure/search_api_gateway.tf
[gcp-search-api-v2-deployment]: ../gcp-search-api-v2/
[search-v2-tfc-config]: ../tfc-configuration/search-api-v2.tf
[publishing-deployment]: ../govuk-publishing-infrastructure/README.md
[variables]: ./variables.tf
[variables-folder]: ../../variables
[quota_preference]: https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/cloud_quotas_quota_preference
[quotas-and-system-limits]: https://docs.cloud.google.com/docs/quotas/quotas