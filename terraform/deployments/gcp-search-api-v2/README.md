# gcp-search-api-v2
This Terraform module is for bootstrapping the search GCP projects. This lays the initial (minimal) groundwork
in GCP for the `search-api-v2` projects to run successfully. 

For other parts of the `search-api-v2` setup, see the [search-api-v2 deployment][search-api-v2-deployment].

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

[search-api-v2-deployment]: ../search-api-v2/README.md
