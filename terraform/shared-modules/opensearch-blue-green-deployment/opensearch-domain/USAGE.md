<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advanced_security_options"></a> [advanced\_security\_options](#input\_advanced\_security\_options) | OpenSearch Advanced Security options | <pre>object({<br/>    anonymous_auth_enabled         = optional(bool, false)<br/>    internal_user_database_enabled = optional(bool, true)<br/>    master_user_options = optional(object({<br/>      master_user_name     = string<br/>      master_user_password = string<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_custom_endpoint"></a> [custom\_endpoint](#input\_custom\_endpoint) | The custom CNAME which points to the OpenSearch domain | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The OpenSearch engine version | `string` | n/a | yes |
| <a name="input_govuk_environment"></a> [govuk\_environment](#input\_govuk\_environment) | Name of the GOV.UK Environment into which this is being deployed | `string` | n/a | yes |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of OpenSearch nodes | `number` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type of the OpenSearch nodes | `string` | n/a | yes |
| <a name="input_opensearch_domain_name"></a> [opensearch\_domain\_name](#input\_opensearch\_domain\_name) | Name for this opensearch domain | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | A list of AWS Security Group IDs to attach to the domain | `list(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of AWS VPC Subnet IDs in which to deploy the OpenSearch nodes | `list(string)` | n/a | yes |
| <a name="input_dedicated_master"></a> [dedicated\_master](#input\_dedicated\_master) | Dedicated master configuration, leave null to disable dedicated master | <pre>object({<br/>    instance_count = number<br/>    instance_type  = string<br/>  })</pre> | `null` | no |
| <a name="input_disable_audit_logs"></a> [disable\_audit\_logs](#input\_disable\_audit\_logs) | Disable sending audit logs to CloudWatch | `bool` | `false` | no |
| <a name="input_disable_enforced_https"></a> [disable\_enforced\_https](#input\_disable\_enforced\_https) | Disable enforced https connections to allow search ES cluster to be imported. | `bool` | `false` | no |
| <a name="input_disable_node_to_node_encryption"></a> [disable\_node\_to\_node\_encryption](#input\_disable\_node\_to\_node\_encryption) | Disable node to node encryption to allow search ES cluster to be imported. | `bool` | `false` | no |
| <a name="input_ebs_options"></a> [ebs\_options](#input\_ebs\_options) | Node EBS volume options, if left null, no EBS volumes will be attached to data nodes in the nodes | <pre>object({<br/>    volume_size = number<br/>    volume_type = optional(string, "gp3")<br/>    throughput  = number<br/>    iops        = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_elasticsearch_domain_additional_tags"></a> [elasticsearch\_domain\_additional\_tags](#input\_elasticsearch\_domain\_additional\_tags) | Add these additional tags to the green Elasticsearch cluster to allow search ES cluster to be imported. | `map(string)` | `null` | no |
| <a name="input_endpoint_tls_security_policy"></a> [endpoint\_tls\_security\_policy](#input\_endpoint\_tls\_security\_policy) | The TLS Security Policy to apply to the OpenSearch domain endpoint. The default is for TLS version 1.2 to 1.3 with perfect forward secrecy cipher suites | `string` | `"Policy-Min-TLS-1-2-PFS-2023-10"` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Engine, either Elasticsearch or OpenSearch | `string` | `"OpenSearch"` | no |
| <a name="input_inline_access_policy_declaration"></a> [inline\_access\_policy\_declaration](#input\_inline\_access\_policy\_declaration) | Attach the opensearch domain access policy inline in the opensearch resource | `bool` | `false` | no |
| <a name="input_log_group_name_overrides"></a> [log\_group\_name\_overrides](#input\_log\_group\_name\_overrides) | n/a | <pre>object({<br/>    index_slow_logs  = string<br/>    search_slow_logs = string<br/>    error_logs       = string<br/>  })</pre> | `null` | no |
| <a name="input_log_group_prefix_override"></a> [log\_group\_prefix\_override](#input\_log\_group\_prefix\_override) | Use a custom prefix for the cloudwatch log group name | `string` | `null` | no |
| <a name="input_log_resource_policy_name_suffix_override"></a> [log\_resource\_policy\_name\_suffix\_override](#input\_log\_resource\_policy\_name\_suffix\_override) | Use this as the aws\_cloudwatch\_log\_resource\_policy name suffix instead of -domain-write to allow search ES cluster to be imported. | `string` | `null` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | How long to retain OpenSearch logs in CloudWatch Logs | `number` | `365` | no |
| <a name="input_multi_az_with_standby_enabled"></a> [multi\_az\_with\_standby\_enabled](#input\_multi\_az\_with\_standby\_enabled) | Whether a multi-AZ domain is turned on with a standby AZ. | `bool` | `true` | no |
| <a name="input_override_aws_elasticsearch_domain_name"></a> [override\_aws\_elasticsearch\_domain\_name](#input\_override\_aws\_elasticsearch\_domain\_name) | Use this as the name of the aws\_elasticsearch\_domain (not as the domain name to talk to this cluster on) to allow search ES cluister to be imported | `string` | `null` | no |
| <a name="input_use_aws_elasticsearch_domain_resource"></a> [use\_aws\_elasticsearch\_domain\_resource](#input\_use\_aws\_elasticsearch\_domain\_resource) | Use an aws\_elasticsearch\_domain resource instead of aws\_opensearch\_domain to allow search ES cluster to be imported | `bool` | `false` | no |
| <a name="input_zone_awareness_enabled"></a> [zone\_awareness\_enabled](#input\_zone\_awareness\_enabled) | Whether to enable OpenSearch AWS Availability Zone awareness | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_opensearch_domain_arn"></a> [opensearch\_domain\_arn](#output\_opensearch\_domain\_arn) | n/a |
| <a name="output_opensearch_endpoint"></a> [opensearch\_endpoint](#output\_opensearch\_endpoint) | n/a |
<!-- END_TF_DOCS -->