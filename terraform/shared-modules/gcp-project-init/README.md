# gcp-project-init

This module is intended to provide a baseline configuration for some essentials when creating a new GCP project.

- Ensure a GCP project is under the appropriate folder with the correct billing details.
- Ensure that the terraform cloud (TFC) service account is added with correct permissions to manage resources within the project.

## Usage

See the examples below, and see [USAGE.md](./USAGE.md) for a complete list of all options with descriptions.

## Examples

### Create a new project
`main.tf`:
```hcl
module "project" {
  source = "../../shared-modules/gcp-project-init"

  project_id   = "gds-bq-processing-dev"
  project_name = "gds-bq-processing-dev"
}
```

### Manage an existing project
Importing the project configuration is quite straight-forward (see `imports.tf` below). Importing the existing `project_owners`, `project_editors` and `project_viewers` is more complicated. Crucially, the plan in TFC will not accurately show the changes if you do not first import them. You will have to choose whether you do add each of the bindings to `imports.tf` (which is very-fiddly) or configure them so that they exactly match current state. TFor example, to configure them explicitly in the module definition you would ensure `project_owners` matches the list of project owners shown in the GCP Cloud Console.
`main.tf`:
```hcl
module "project" {
  source = "../../shared-modules/gcp-project-init"

  project_id   = "gds-bq-processing-dev"
  project_name = "gds-bq-processing-dev"
  project_owners = ["existing.user@email.com", "existing.service.account@email.com"]
}
```

`imports.tf`
```hcl
import {
  id = "gds-bq-processing-dev"
  to = google_project.project
}
```