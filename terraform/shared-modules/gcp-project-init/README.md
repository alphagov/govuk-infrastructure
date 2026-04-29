# gcp-project-init

This module is intended to provide a baseline configuration for some essentials when creating a new GCP project.

- Ensure a GCP project is under the appropriate folder with the correct billing details.
- Ensure that the terraform cloud (TFC) service account is added with correct permissions to manage resources within the project.
- Optionally enforce any additional project-level permissions for users, groups and service accounts.

## Usage

See the examples below, and see [USAGE.md](./USAGE.md) for a complete list of all options with descriptions.

If you use this module in your workspace you should add its path to your `trigger_patterns` to ensure changes to the module are included in your workspace plans. E.g.:

```hcl
trigger_patterns = [
  ..., # your existing paths
  "/terraform/shared-modules/gcp-project-init/**/*",
]
```

## Examples

### Create a new project
`main.tf`
```hcl
module "managed_project" {
  source = "../../shared-modules/gcp-project-init"

  project_id   = "my-project-id"
  project_name = "my-project-name"
}
```

### Manage an existing project
Importing the project configuration is quite straight-forward (see `imports.tf` below). Importing the existing `project_owners`, `project_editors` and `project_viewers` is more complicated. Crucially, the plan in TFC will not accurately show the changes if you do not first import them. You will have to choose whether you do add each of the bindings to `imports.tf` (which is very fiddly) or configure them so that they exactly match current state. For example, to configure them explicitly in the module definition you would ensure `project_owners` matches the list of project owners shown in the GCP Cloud Console.

`main.tf`
```hcl
module "managed_project" {
  source = "../../shared-modules/gcp-project-init"

  project_id   = "my-project-id"
  project_name = "my-project-name"
  project_owners = [
    "user:existing.user@email.com",
    "serviceAccount:existing.service.account@email.com",
    "group:existing.group@email.com",
  ]
}
```

`imports.tf`
```hcl
import {
  id = "my-project-id"
  to = module.managed_project.google_project.project
}
```

### Overriding defaults
The terraform SA will _always_ be added as project owner whenever you use this module, even if `project_owners` is empty. The default value is set to `terraform-cloud-production@govuk-production.iam.gserviceaccount` but you can change the terraform SA used by specifying a value for `terraform_service_account`. Similarly, the `billing_account` and `folder_id` have default values that work for the Insights & Analytics Team but you can override these values if you need to [see USAGE.md](/terraform/shared-modules/gcp-project-init/USAGE.md). For example - 

```hcl
module "managed_project" {
  source = "../../shared-modules/gcp-project-init"

  project_id   = "my-project-id"
  project_name = "my-project-name"
  terraform_service_account = "different-service-account@email.com"
  billing_account = "my-different-billing-account"
  folder_id = "my-different-folder-id"
}
```
