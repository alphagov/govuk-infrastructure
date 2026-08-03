# gcp-search-api-v2
This Terraform module is for bootstrapping the search GCP projects. This lays the initial (minimal) groundwork
in GCP for the `search-api-v2` projects to run successfully. 

For other parts of the `search-api-v2` setup, see the [search-api-v2 deployment][search-api-v2-deployment], and the
[tfc-configurations][search-v2-tfc-config] and [variables][variables].

## Resources
This module manages the following resources:
- For every desired environment (integration, staging, prod), through the `modules/environment`
  child module:
  - A GCP project

This covers initial setup of the GCP projects, including defining the projects and assigning broad access
roles to access groups and Terraform.

## Applying this module
This module uses Terraform Cloud for remote state storage, but is intended to be manually run *locally* by a
user with "interactive" end-user access to both Terraform Cloud and Google Cloud Platform. (This is to
avoid a chicken-and-egg problem around having to manually create service accounts to manage
meta-resources like service accounts or projects.)

### Authentication
Before you can use this module, you must:
- use `terraform login` to authenticate to Terraform Cloud
- use `gcloud auth application-default login` to authenticate to GCP

### Using the Terraform cli
Once you have [authenticated](#authentication), run the module using the Terraform cli. For example:

```bash
terraform plan
```

Values for `google_cloud_folder` and `google_cloud_billing_account` will need to be specified:
- `google_cloud_folder` is a numerical ID for the folder the projects live in, in GCP.
  For an existing folder, this can be found in the GCP console.
  Navigate to the 'all' tab in the 'project picker' in GCP to view the folder structure, including the folder IDs.
- `google_cloud_billing_account` is an ID including alphanumeric characters and hyphens.
  For an existing project, this can be found in the GCP console under "Billing".

These values can be set interactively in the console when running the cli, or these can be provided through a (gitignored)
`local.auto.tfvars` file, or they can be provided to the `terraform` command using the `-var` argument:

```bash
terraform plan -var google_cloud_billing_account=<account-id> -var google_cloud_folder=<folder-id>
```

## Additional information
### Adding GCP quota overrides
Quota overrides are used to cap limits under values that have been set by default or by admin/producer overrides.
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
You will need to manually request a quota increase from Google through the console first.

[search-api-v2-deployment]: ../search-api-v2/
[search-v2-tfc-config]: ../tfc-configuration/search-api-v2.tf
[variables]: ../../variables