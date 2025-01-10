# Search API V2 Terraform Cloud Module

This module has been migrated into this repo from `search-v2-infrastructure/terraform/meta/modules/environment` as part of a project to bring it in line with current standard practices for infrastructure. It is called from `govuk-infrastructure/terraform/deployments/tfc-configuration/search-api-v2.tf` to create the following workspaces in Terraform Cloud:

- search-api-v2-integration
- search-api-v2-staging
- search-api-v2-production

The original module created resources for GCP as well as TFC, so a decision was made to split them out to conform more closely with standard practices, and to have them created separately. As all the resources already existed, import blocks have been used in `search-api-v2.tf` so that the infrastructure did not get duplicated. In it's old format, any updates had to be run manually from a laptop so the main benefit of this migration is that changes to this code should now get applied automatically.
