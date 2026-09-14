<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_tfe"></a> [tfe](#provider\_tfe) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_current_live_domain"></a> [current\_live\_domain](#input\_current\_live\_domain) | Either blue, or green, specifying the current live OpenSearch domain | `string` | n/a | yes |
| <a name="input_govuk_environment"></a> [govuk\_environment](#input\_govuk\_environment) | Name of the GOV.UK Environment into which this is being deployed | `string` | n/a | yes |
| <a name="input_launch_blue_domain"></a> [launch\_blue\_domain](#input\_launch\_blue\_domain) | Launch the blue OpenSearch domain | `bool` | n/a | yes |
| <a name="input_launch_green_domain"></a> [launch\_green\_domain](#input\_launch\_green\_domain) | Launch the green OpenSearch domain | `bool` | n/a | yes |
| <a name="input_opensearch_domain_name"></a> [opensearch\_domain\_name](#input\_opensearch\_domain\_name) | Name for this opensearch domain, for blue/green deploys this will be suffixed with -blue or -green | `string` | n/a | yes |
| <a name="input_secrets_manager_prefix"></a> [secrets\_manager\_prefix](#input\_secrets\_manager\_prefix) | The name to prefix the Secrets Manager Secret with (e.g. govuk/govuk-ai-accelerator), this will have /opensearch appended | `string` | n/a | yes |
| <a name="input_account_ids_allowed_to_read_domain_snapshots"></a> [account\_ids\_allowed\_to\_read\_domain\_snapshots](#input\_account\_ids\_allowed\_to\_read\_domain\_snapshots) | A list of AWS Account IDS (in addition to the current) which will be allowed to read snapshots from the snapshot bucket created by this module | `list(string)` | `[]` | no |
| <a name="input_blue_cluster_options"></a> [blue\_cluster\_options](#input\_blue\_cluster\_options) | n/a | <pre>object({<br/>    engine         = optional(string, "OpenSearch")<br/>    engine_version = string<br/>    dedicated_master = optional(object({<br/>      instance_count = number<br/>      instance_type  = string<br/>    }))<br/>    instance_count                = number<br/>    instance_type                 = string<br/>    zone_awareness_enabled        = optional(bool, true)<br/>    multi_az_with_standby_enabled = optional(bool, true)<br/>    advanced_security_options = optional(object({<br/>      anonymous_auth_enabled         = optional(bool, false)<br/>      internal_user_database_enabled = optional(bool, true)<br/>    }))<br/>    endpoint_tls_security_policy = optional(string)<br/>    ebs_options = optional(object({<br/>      volume_size = number<br/>      volume_type = string<br/>      throughput  = number<br/>      iops        = optional(number)<br/>    }))<br/>    create_vpc_endpoint = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_create_original_snapshot_bucket"></a> [create\_original\_snapshot\_bucket](#input\_create\_original\_snapshot\_bucket) | Temporary: Create the correctly named snapshot bucket | `bool` | `false` | no |
| <a name="input_create_remote_connection_to_import_to_blue_from_green"></a> [create\_remote\_connection\_to\_import\_to\_blue\_from\_green](#input\_create\_remote\_connection\_to\_import\_to\_blue\_from\_green) | Create an outgoing connection from the blue cluster to the green cluster to allow remote reimport with green as source (remote) and blue as destination (local) | `bool` | `false` | no |
| <a name="input_create_remote_connection_to_import_to_green_from_blue"></a> [create\_remote\_connection\_to\_import\_to\_green\_from\_blue](#input\_create\_remote\_connection\_to\_import\_to\_green\_from\_blue) | Create an outgoing connection from the green cluster to the blue cluster to allow remote reimport with blue as source (remote) and green as destination (local) | `bool` | `false` | no |
| <a name="input_green_cluster_options"></a> [green\_cluster\_options](#input\_green\_cluster\_options) | n/a | <pre>object({<br/>    engine         = optional(string, "OpenSearch")<br/>    engine_version = string<br/>    dedicated_master = optional(object({<br/>      instance_count = number<br/>      instance_type  = string<br/>    }))<br/>    instance_count                = number<br/>    instance_type                 = string<br/>    zone_awareness_enabled        = optional(bool, true)<br/>    multi_az_with_standby_enabled = optional(bool, true)<br/>    advanced_security_options = optional(object({<br/>      anonymous_auth_enabled         = optional(bool, false)<br/>      internal_user_database_enabled = optional(bool, true)<br/>    }))<br/>    endpoint_tls_security_policy = optional(string)<br/>    ebs_options = optional(object({<br/>      volume_size = number<br/>      volume_type = string<br/>      throughput  = number<br/>      iops        = optional(number)<br/>    }))<br/>    create_vpc_endpoint = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_override_old_snapshot_bucket_name"></a> [override\_old\_snapshot\_bucket\_name](#input\_override\_old\_snapshot\_bucket\_name) | Set the name of the old snapshot bucket to this allow search ES cluster to be imported. | `string` | `null` | no |
| <a name="input_read_snapshots_from_environments"></a> [read\_snapshots\_from\_environments](#input\_read\_snapshots\_from\_environments) | The environment names which this deployment should be able to read snapshots from as well as from its own | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_old_s3_snapshot_bucket_arn"></a> [old\_s3\_snapshot\_bucket\_arn](#output\_old\_s3\_snapshot\_bucket\_arn) | ARN of the S3 bucket used for snapshots |
| <a name="output_old_s3_snapshot_bucket_name"></a> [old\_s3\_snapshot\_bucket\_name](#output\_old\_s3\_snapshot\_bucket\_name) | Name of the S3 bucket used for snapshots |
| <a name="output_opensearch_cname"></a> [opensearch\_cname](#output\_opensearch\_cname) | The fully qualified domain name of the route53 record which points to the live OpenSearch domain |
| <a name="output_opensearch_domain_arns"></a> [opensearch\_domain\_arns](#output\_opensearch\_domain\_arns) | A map of the AWS OpenSearch domain ARNS for the blue and green clusters,  clusters which haven't be launched will be null |
| <a name="output_opensearch_domain_endpoints"></a> [opensearch\_domain\_endpoints](#output\_opensearch\_domain\_endpoints) | A map of the AWS OpenSearch domain ARNS for the blue and green clusters,  clusters which haven't be launched will be null |
| <a name="output_opensearch_domain_names"></a> [opensearch\_domain\_names](#output\_opensearch\_domain\_names) | A map of the OpenSearch domain names for the blue and green clusters, clusters which haven't be launched will be null |
| <a name="output_opensearch_iam_role_arn"></a> [opensearch\_iam\_role\_arn](#output\_opensearch\_iam\_role\_arn) | The ARN of the IAM role used for OpenSearch to read and write Snapshots |
| <a name="output_opensearch_iam_role_name"></a> [opensearch\_iam\_role\_name](#output\_opensearch\_iam\_role\_name) | The name of the IAM role used for OpenSearch to read and write Snapshots |
| <a name="output_remote_connection_vpc_endpoints"></a> [remote\_connection\_vpc\_endpoints](#output\_remote\_connection\_vpc\_endpoints) | n/a |
| <a name="output_s3_snapshot_bucket_arn"></a> [s3\_snapshot\_bucket\_arn](#output\_s3\_snapshot\_bucket\_arn) | ARN of the S3 bucket used for snapshots |
| <a name="output_s3_snapshot_bucket_name"></a> [s3\_snapshot\_bucket\_name](#output\_s3\_snapshot\_bucket\_name) | Name of the S3 bucket used for snapshots |
| <a name="output_secrets_manager_secret_name"></a> [secrets\_manager\_secret\_name](#output\_secrets\_manager\_secret\_name) | The name of the Secrets Manager secret which contains the OpenSearch master user details |
| <a name="output_vpc_endpoints"></a> [vpc\_endpoints](#output\_vpc\_endpoints) | n/a |
<!-- END_TF_DOCS -->