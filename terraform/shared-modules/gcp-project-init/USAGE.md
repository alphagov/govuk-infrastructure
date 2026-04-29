<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID to manage. | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the GCP project. | `string` | n/a | yes |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | The default billing account ID to associate with the project. | `string` | `"015C7A-FAF970-B0D375"` | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | The Folder ID to create the project under. | `string` | `"278098142879"` | no |
| <a name="input_project_editors"></a> [project\_editors](#input\_project\_editors) | A list of IAM members (users, groups, or SAs) to be granted roles/editor. | `list(string)` | `[]` | no |
| <a name="input_project_owners"></a> [project\_owners](#input\_project\_owners) | A list of IAM members (users, groups, or SAs) to be granted roles/owner. | `list(string)` | `[]` | no |
| <a name="input_project_viewers"></a> [project\_viewers](#input\_project\_viewers) | A list of IAM members (users, groups, or SAs) to be granted roles/viewer. | `list(string)` | `[]` | no |
| <a name="input_terraform_service_account"></a> [terraform\_service\_account](#input\_terraform\_service\_account) | The Terraform service account email to be hard-coded as an owner. | `string` | `"serviceAccount:terraform-cloud-production@govuk-production.iam.gserviceaccount.com"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_binding_project_editors"></a> [iam\_binding\_project\_editors](#output\_iam\_binding\_project\_editors) | The project's IAM binding for roles/editor |
| <a name="output_iam_binding_project_owners"></a> [iam\_binding\_project\_owners](#output\_iam\_binding\_project\_owners) | The project's IAM binding for roles/owner |
| <a name="output_iam_binding_project_viewers"></a> [iam\_binding\_project\_viewers](#output\_iam\_binding\_project\_viewers) | The project's IAM binding for roles/viewer |
| <a name="output_project"></a> [project](#output\_project) | The entire google\_project resource object. |
<!-- END_TF_DOCS -->