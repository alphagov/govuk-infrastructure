<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advanced_security_options"></a> [advanced\_security\_options](#input\_advanced\_security\_options) | OpenSearch Advanced Security options | <pre>object({<br/>    anonymous_auth_enabled         = optional(bool, false)<br/>    internal_user_database_enabled = optional(bool, true)<br/>    master_user_options = object({<br/>      master_user_name     = string<br/>      master_user_password = string<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_custom_endpoint"></a> [custom\_endpoint](#input\_custom\_endpoint) | The custom CNAME which points to the OpenSearch domain | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The OpenSearch engine version | `string` | n/a | yes |
| <a name="input_govuk_environment"></a> [govuk\_environment](#input\_govuk\_environment) | Name of the GOV.UK Environment into which this is being deployed | `string` | n/a | yes |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of OpenSearch nodes | `number` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type of the OpenSearch nodes | `string` | n/a | yes |
| <a name="input_opensearch_domain_name"></a> [opensearch\_domain\_name](#input\_opensearch\_domain\_name) | Name for this opensearch domain, for blue/green stacks this will be suffixed with -blue or -green | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | A list of AWS Security Group IDs to attach to the domain | `list(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of AWS VPC Subnet IDs in which to deploy the OpenSearch nodes | `list(string)` | n/a | yes |
| <a name="input_cloudwatch_log_retention_in_days"></a> [cloudwatch\_log\_retention\_in\_days](#input\_cloudwatch\_log\_retention\_in\_days) | How long to retain OpenSearch logs in CloudWatch Logs | `number` | `365` | no |
| <a name="input_dedicated_master"></a> [dedicated\_master](#input\_dedicated\_master) | Dedicated master configuration, leave null to disable dedicated master | <pre>object({<br/>    instance_count = number<br/>    instance_type  = string<br/>  })</pre> | `null` | no |
| <a name="input_ebs_options"></a> [ebs\_options](#input\_ebs\_options) | Node EBS volume options, if left null, no EBS volumes will be attached to data nodes in the nodes | <pre>object({<br/>    volume_size = number<br/>    volume_type = optional(string, "gp3")<br/>    throughput  = number<br/>  })</pre> | `null` | no |
| <a name="input_endpoint_tls_security_policy"></a> [endpoint\_tls\_security\_policy](#input\_endpoint\_tls\_security\_policy) | The TLS Security Policy to apply to the OpenSearch domain endpoint. The default is for TLS version 1.2 to 1.3 with perfect forward secrecy cipher suites | `string` | `"Policy-Min-TLS-1-2-PFS-2023-10"` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Engine, either Elasticsearch or OpenSearch | `string` | `"OpenSearch"` | no |
| <a name="input_multi_az_with_standby_enabled"></a> [multi\_az\_with\_standby\_enabled](#input\_multi\_az\_with\_standby\_enabled) | Whether a multi-AZ domain is turned on with a standby AZ. | `bool` | `true` | no |
| <a name="input_zone_awareness_enabled"></a> [zone\_awareness\_enabled](#input\_zone\_awareness\_enabled) | Whether to enable OpenSearch AWS Availability Zone awareness | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_opensearch_endpoint"></a> [opensearch\_endpoint](#output\_opensearch\_endpoint) | n/a |
<!-- END_TF_DOCS -->